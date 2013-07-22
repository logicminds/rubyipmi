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

    def find_fix(result)
      if result
        # The errorcode code hash contains the fix
        begin
          fix = ErrorCodes.search(result)
          @options.merge_notify!(fix)
        rescue
          raise "#{result}"
        end
      end
    end

  end
end