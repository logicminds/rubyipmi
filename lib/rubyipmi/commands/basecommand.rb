require "observer"
require 'tempfile'
require 'rubyipmi'

module Rubyipmi

  class BaseCommand
    include Observable
    attr_reader :cmd, :max_retry_count
    attr_accessor :available_drivers, :options, :passfile
    attr_reader :lastcall, :result

    def logger
      Rubyipmi.logger
    end

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
        logger.error("#{commandname} command not found, is #{commandname} installed?") if logger
        raise "#{commandname} command not found, is #{commandname} installed?"
      end
      location
    end

    # Use this function to run the command line tool, it will inherently use the options hash for all options
    # That need to be specified on the command line
    def runcmd
      @success = false
      @success = run
      logger.debug(@lastcall.inspect) unless @lastcall.nil? if logger
      logger.debug(@result) unless @result.nil? if logger
      @success
    end

    def configure_drivers(current_option = nil)
      @available_drivers = all_drivers
      available_drivers.delete(current_option)
    end

    def run
      # we search for the command everytime just in case its removed during execution
      # we also don't want to add this to the initialize since mocking is difficult and we don't want to
      # throw errors upon object creation
      process_status = false
      @cmd = locate_command(@cmdname)
      setpass
      configure_drivers
      @result = nil
      logger.debug(makecommand) if logger
      begin
        command = makecommand
        @lastcall = "#{command}"
        @result = `#{command} 2>&1`
        # sometimes the command tool does not return the correct result, validate it with additional code
        process_status = validate_status($?)
      rescue
        find_fix
        retry
      ensure
        removepass
        return process_status
      end
    end

    def update(opts)
      @options.merge!(opts)
    end

  # This method will check if the results are really valid as the exit code can be misleading and incorrect
    def validate_status(exitstatus)
      raise "Error occurred" unless exitstatus.success?

      true
    end
  end
end