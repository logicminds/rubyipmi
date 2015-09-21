module Rubyipmi
  module Ipmitool
    class ErrorCodes
      @@codes = {
        "Authentication type NONE not supported\nAuthentication type NONE not supported\n" \
        "Error: Unable to establish LAN session\nGet Device ID command failed\n" => {"I" => "lanplus"},
        "Authentication type NONE not supported" => {"I" => "lanplus"},
        "Error: Unable to establish LAN session\nGet Device ID command failed\n" => {"I" => "lanplus"}
      }

      def self.length
        @@codes.length
      end

      def self.code
        @@codes
      end

      def self.search(code)
        fix = @@codes.fetch(code, nil)
        if fix.nil?
          @@codes.each do |error, result|
            # the error should be a subset of the actual erorr
            return result if code =~ /.*#{error}.*/i
          end
        else
          return fix
        end
        raise "No Fix found" if fix.nil?
      end

      def throwError
        # Find out what kind of error is happening, parse results
        # Check for authentication or connection issue

        if @result =~ /timeout|timed\ out/
          code = "ipmi call: #{@lastcall} timed out"
          raise code
        else
          code = @result.split(":").last.chomp.strip unless @result.empty?
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
