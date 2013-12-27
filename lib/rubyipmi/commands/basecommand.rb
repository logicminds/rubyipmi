require "observer"
require 'tempfile'
require 'open3'
require 'timeout'

module Rubyipmi
  class IpmiTimeout < StandardError; end
  class InvalidExitStatus < StandardError; end
  class AutoFixFailed < StandardError; end

  class BaseCommand
    include Observable
    attr_reader :cmd, :max_retry_count
    attr_accessor :options, :passfile, :timeout
    attr_reader :lastcall, :result

    def makecommand
      # override in subclass
    end

    def setpass
      @passfile = Tempfile.new('')
    end

    def removepass
      @passfile.unlink
    end

    def dump_command
      makecommand
    end

    def initialize(commandname, opts = ObservableHash.new, timeout=5)
      # This will locate the command path or raise an error if not found
      @cmdname = commandname
      @options = opts
      @options.add_observer(self)
      @timeout = timeout
    end

    def locate_command(commandname)
      location = `which #{commandname}`.strip
      if not $?.success?
        raise "#{commandname} command not found, is #{commandname} installed?"
      end
      return location
    end

    # Use this function to run the command line tool, it will inherently use the options hash for all options
    # That need to be specified on the command line
    def runcmd(debug=false)
      @success = false
      @success = run(debug)
      if ENV['rubyipmi_debug'] == 'true'
        puts @lastcall.inspect unless @lastcall.nil?
      end
      return @success
    end

    def run(debug=false)
      # we search for the command everytime just in case its removed during execution
      # we also don't want to add this to the initialize since mocking is difficult and we don't want to
      # throw errors upon object creation
      retrycount = 0
      process_status = false
      @cmd = locate_command(@cmdname)
      setpass
      @result = nil
      @exit_status = nil
      if debug
        # Log error
        return makecommand
      end

      begin
        command = makecommand
        @lastcall = "#{command}"
        Open3.popen2e(command, :pgroup => true) do |i,o,thr|
          begin
            Timeout.timeout(@timeout) do
              # wait for thread
              thr.join
              @result = o.read
            end
          rescue Timeout::Error
            # kill process group
            Process.kill('TERM', -Process.getpgid(thr.pid))
            raise IpmiTimeout.new(@lastcall)
          ensure
            @exit_status = thr.value
          end
        end

        # sometimes the command tool does not return the correct result
        process_status = validate_status(@exit_status)
      rescue InvalidExitStatus
        if retrycount < max_retry_count
          find_fix(@result)
          retrycount = retrycount.next
          retry
        else
          raise AutoFixFailed,
            "Exhausted all auto fixes, cannot determine what the problem is"
        end
      ensure
        removepass
        process_status
      end

    end

    # The findfix method acts like a recursive method and applies fixes defined in the errorcodes
    # If a fix is found it is applied to the options hash, and then the last run command is retried
    # until all the fixes are exhausted or a error not defined in the errorcodes is found
    # this must be overrided in the subclass, as there are no generic errors that fit both providers
    def find_fix(result)
      if result
        # The errorcode code hash contains the fix
        begin
          fix = ErrorCodes.search(result)
          @options.merge_notify!(fix)

        rescue
          raise "Could not find fix for error code: \n#{result}"
        end
      end
    end

    def update(opts)
          @options.merge!(opts)
    end

  # This method will check if the results are really valid as the exit code can be misleading and incorrect
    def validate_status(exitstatus)
      # override in child class if needed
      if ! exitstatus.success?
         raise InvalidExitStatus, "Error occured"
      else
        return true
      end
    end


  end
end
