require "observer"
require 'tempfile'

module Rubyipmi

  class BaseCommand
    include Observable


    attr_reader :cmd
    attr_accessor :options, :passfile
    attr_reader :lastcall

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

    def initialize(commandname, opts = ObservableHash.new)
      # This will locate the command path or raise an error if not found
      @cmdname = commandname
      @options = opts
      @options.add_observer(self)
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

      result = catch(:ipmierror){
        @success = run(debug)
      }
      # if error occurs try and find the fix
      if result and not @success
        findfix(result, nil, debug, "runcmd")
      end
      return @success


    end


    def runcmd_without_opts(args=[], debug=false)

      @success = false
      result = catch(:ipmierror){
        @success = run_without_opts(args, debug)

      }
      # if error occurs try and find the fix and rerun the method
      if result and not @success
        findfix(result, args, debug, "runcmd_with_args")
      end
      return @success
    end

    # The findfix method acts like a recursive method and applies fixes defined in the errorcodes
    # If a fix is found it is applied to the options hash, and then the last run command is retried
    # until all the fixes are exhausted or a error not defined in the errorcodes is found
    def findfix(result, args, debug, runmethod)
      if result
        # The errorcode code hash contains the fix
        fix = ErrorCodes.search(result)
        if not fix
          raise "#{result}"
        else
          @options.merge_notify!(fix)
          # retry the last called method
          # its quicker to explicitly call these commands than calling a command block
          if runmethod == "run"
            run(debug)
          else
            run_without_opts(args, debug)
          end

        end

      end
    end


    def run(debug=false)
      # we search for the command everytime just in case its removed during execution
      # we also don't want to add this to the initialize since mocking is difficult and we don't want to
      # throw errors upon object creation
      @cmd = locate_command(@cmdname)
      setpass
      @result = nil
      command = makecommand
      if debug
        return command
      end

      @lastcall = "#{command}"
      @result = `#{command} 2>&1`
      removepass
      #puts "Last Call: #{@lastcall}"

      # sometimes the command tool doesnt return the correct result
      process_status = validate_status($?)

      if not process_status
        throwError
      end
      return process_status
    end



    def run_without_opts(args=[], debug=false)
      setpass
      @result = ""
      if debug
        return "#{cmd} #{args.join(" ")}"
      else
        @lastcall = "#{cmd} #{args.join(" ")}"
        @result = `#{cmd} #{args.join(" ")} 2>&1`
        removepass
      end

      process_status = validate_status($?)

      if not process_status
        throwError
      end
      return process_status


    end

    def update(opts)
          @options.merge!(opts)
          #puts "Options were updated: #{@options.inspect}"
    end




    # This method will check if the results are really valid as the exit code can be misleading and incorrect
    def validate_status(exitstatus)
      # override in child class if needed
      return exitstatus.success?

    end

    def throwError
      # Find out what kind of error is happening, parse results
      # Check for authentication or connection issue
      #puts "ipmi call: #{@lastcall}"

      if @result =~ /timeout|timed\ out/
        code = "ipmi call: #{@lastcall} timed out"
        raise code
      else
        code = @result.split(":").last.chomp.strip if not @result.empty?
      end
      case code
        when "invalid hostname"
          raise code
        when "password invalid"
          raise code
        when "username invalid"
          raise code
        else
          throw :ipmierror, code
      end

    end



  end
end