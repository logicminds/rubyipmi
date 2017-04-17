module Rubyipmi::Ipmitool

  class BaseCommand < Rubyipmi::BaseCommand

    def setpass
      super
      @options["f"] = @passfile.path
      @passfile.write "#{@options["P"]}"
      @passfile.rewind
      @passfile.close
    end

    def makecommand
      args = ''
      # need to format the options to ipmitool format
      @options.each do  |k,v|
        # must remove from command line as its handled via conf file
        next if k == "P"
        next if k == "cmdargs"
        args << " -#{k} #{v}"
      end

      # since ipmitool requires commands to be in specific order

      args << ' ' + options.fetch('cmdargs', '')

      return "#{cmd} #{args.lstrip}"
    end

    def all_drivers
      Rubyipmi::Ipmitool::Connection::DRIVERS_MAP.values
    end

    def configure_drivers
      super(@options["I"])
    end

    # Try a different driver if the previous one didn't work
    def find_fix
      if (new_driver = available_drivers.pop)
        @options.merge_notify!("I" => new_driver)
      else
        logger.error("Exhausted all auto fixes, cannot determine what the problem is") if logger
        raise "Exhausted all auto fixes, cannot determine what the problem is"
      end
    end
  end
end