module Rubyipmi::Freeipmi

  class BaseCommand < Rubyipmi::BaseCommand

    def setpass
      super
      @options["config-file"] = @passfile.path
      @passfile.write "password #{@options["password"]}\n"
      @passfile.write "username #{@options["username"]}"

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
      return "#{cmd} #{args.rstrip}"
    end

    # This method will check if the results are really valid as the exit code can be misleading and incorrect
    def validate_status(exitstatus)

      case @cmdname
        when "ipmipower"
          # until ipmipower returns the correct exit status this is a hack
          # essentially any result greater than 23 characters is an error
          if @result.length > 23
            raise "Error occured"
          end
        when "bmc-config"
          if @result.length > 100
            return true
          end
        else
          if exitstatus.success?
            return true
          else
            raise "Error occured"
          end

      end
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