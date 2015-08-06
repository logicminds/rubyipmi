require 'rubyipmi/freeipmi/errorcodes'

module Rubyipmi::Freeipmi

  class BaseCommand < Rubyipmi::BaseCommand

    def setpass
      super
      @options["config-file"] = @passfile.path
      @passfile.write "username #{@options["username"]}\n"
      @passfile.write "password #{@options["password"]}\n"
      @passfile.close
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

    def all_drivers
      Rubyipmi::Freeipmi::Connection::DRIVERS_MAP.values
    end

    def configure_drivers
      super(@options["driver-type"])
    end

    # Try a different driver if the previous one didn't work
    def find_fix
      if (new_driver = available_drivers.pop)
        @options.merge_notify!("driver-type" => new_driver)
      else
        logger.error("Exhausted all auto fixes, cannot determine what the problem is") if logger
        raise "Exhausted all auto fixes, cannot determine what the problem is"
      end
    end
  end
end