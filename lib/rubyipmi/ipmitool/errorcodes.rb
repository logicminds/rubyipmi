module Rubyipmi
  module Ipmitool
    class ErrorCodes
      CODES = {
        "Authentication type NONE not supported\nAuthentication type NONE not supported\n" \
        "Error: Unable to establish LAN session\nGet Device ID command failed\n" => {"I" => "lanplus"},
        "Authentication type NONE not supported" => {"I" => "lanplus"},
        "Error: Unable to establish LAN session\nGet Device ID command failed\n" => {"I" => "lanplus"}
      }

      def self.length
        CODES.length
      end

      def self.code
        CODES
      end

      def self.search(code)
        fix = CODES.fetch(code, nil)
        if fix.nil?
          CODES.each do |error, result|
            # the error should be a subset of the actual erorr
            return result if code =~ /.*#{error}.*/i
          end
        else
          return fix
        end
        raise "No Fix found" if fix.nil?
      end
    end
  end
end
