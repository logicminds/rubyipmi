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
          puts code
          if error =~ /^#{Regexp.escape(code)}/i
            return fix
          end
        end
      end

    end


  end
end

