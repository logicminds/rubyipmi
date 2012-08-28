module Rubyipmi::Freeipmi

  class BaseCommand < Rubyipmi::BaseCommand

    def setpass
      super
      @options["config-file"] = @passfile.path
      @passfile.puts "password #{@options["password"]}\n"
      @passfile.puts "username #{@options["username"]}"

      @passfile.close
    end

    def makecommand
      # need to format the options to freeipmi format
      args = @options.collect { |k, v|
        if not v
          "--#{k}"
        else
          "--#{k}=#{v}"
        end
      }.join(" ")
      # must remove from command line as its handled via conf file
      args.delete("--password")
      args.delete("--username")


      return "#{cmd} #{args}"
    end

    # This method will check if the results are really valid as the exit code can be misleading and incorrect
    def validate_status(exitstatus)
      case @cmdname
        when "ipmipower"
          # until ipmipower returns the correct exit status this is a hack
          # essentially any result greater than 23 characters is an error
          if @result.length > 23
            return false
          end
        when "bmc-config"
          if @result.length > 100
            return true
          end
      end
      return exitstatus.success?

    end

    # The findfix method acts like a recursive method and applies fixes defined in the errorcodes
    # If a fix is found it is applied to the options hash, and then the last run command is retried
    # until all the fixes are exhausted or a error not defined in the errorcodes is found
    def findfix(result, args, debug, runmethod)
      if result
        # The errorcode code hash contains the fix
        fix = Rubyipmi::Freeipmi::ErrorCodes.code[result]
        if not fix
          raise "#{result}"
        else
          @options.merge_notify!(fix)
          # retry the last called method
          # its quicker to explicitly call these commands than calling a command block
          if runmethod == "runcmd"
            runcmd(debug)
          else
            runcmd_without_opts(args, debug)
          end

        end

      end
    end
  end
end