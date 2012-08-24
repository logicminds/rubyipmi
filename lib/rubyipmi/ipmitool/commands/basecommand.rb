module Rubyipmi::Ipmitool

  class BaseCommand < Rubyipmi::BaseCommand

    def makecommand
      args = ""
      # need to format the options to ipmitool format
      @options.each do  |k,v|
        next if k == "cmdargs"
        args << "-#{k} #{v} "
      end
      # since ipmitool requires commands to be in specific order
      args << " " + options["cmdargs"]

      return "#{cmd} #{args}"
    end


    # The findfix method acts like a recursive method and applies fixes defined in the errorcodes
    # If a fix is found it is applied to the options hash, and then the last run command is retried
    # until all the fixes are exhausted or a error not defined in the errorcodes is found
    def findfix(result, args, debug, runmethod)
      if result
        # The errorcode code hash contains the fix
        fix = Rubyipmi::Ipmitool::ErrorCodes.code[result]

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
    def throwError
      # Find out what kind of error is happening, parse results
      # Check for authentication or connection issue
      #puts "ipmi call: #{@lastcall}"

      if @result =~ /timeout|timed\ out/
        code = "ipmi call: #{@lastcall} timed out"
        raise code
      else
        # ipmitool spits out many errors so for now we will just take the first error
        code = @result.split(/\r\n/).first if not @result.empty?
      end
      throw :ipmierror, code
    end


  end
end