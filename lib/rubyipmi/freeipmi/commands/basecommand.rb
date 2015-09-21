require 'rubyipmi/freeipmi/errorcodes'

module Rubyipmi::Freeipmi
  class BaseCommand < Rubyipmi::BaseCommand
    def setpass
      super
      @options["config-file"] = @passfile.path
      @passfile.write "username #{@options['username']}\n"
      @passfile.write "password #{@options['password']}\n"
      @passfile.close
    end

    def max_retry_count
      @max_retry_count ||= Rubyipmi::Freeipmi::ErrorCodes.length
    end

    def makecommand
      # need to format the options to freeipmi format
      args = @options.collect { |k, v|
        # must remove from command line as its handled via conf file
        next if k == 'password'
        next if k == 'username'
        if not v
          "--#{k}"
        else
          "--#{k}=#{v}"
        end
      }.join(" ")

      "#{cmd} #{args.rstrip}"
    end

    # This method will check if the results are really valid as the exit code can be misleading and incorrect
    # this is required because freeipmi in older version always returned 0 even if an error occured
    def validate_status(exitstatus)
      case @cmdname
      when "ipmipower"
        # until ipmipower returns the correct exit status this is a hack
        # essentially any result greater than 23 characters is an error
        raise "Error occurred" if @result.length > 23
      when "bmc-config"
        if @result.length > 100 and exitstatus.success?
          return true
        else
          raise "Error occurred"
        end
      else
        super
      end
    end

    # The findfix method acts like a recursive method and applies fixes defined in the errorcodes
    # If a fix is found it is applied to the options hash, and then the last run command is retried
    # until all the fixes are exhausted or a error not defined in the errorcodes is found
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
  end
end
