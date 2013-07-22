module Rubyipmi
  module Ipmitool
    class ErrorCodes

      @@codes = {
          "Authentication type NONE not supported" => {"I" => "lanplus"},
          "RuntimeError: Unable to establish LAN session" => {"I" => "lanplus"},
          "Unable to establish LAN session" => {"I" => "lanplus"}


      }

      def self.code
        @@codes
      end

      def self.search(code)
        @@codes.each do | error, fix |
          if code =~ /^#{Regexp.escape(error)}/i
            return fix
          end
        end
        raise "No Fix found"

      end


      def throwError
        # Find out what kind of error is happening, parse results
        # Check for authentication or connection issue

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
            raise :ipmierror, code
        end
      end


    end




  end
end

