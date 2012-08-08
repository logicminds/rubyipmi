module Rubyipmi
  module Ipmitool
    class ErrorCodes

      @@code = {
          "Authentication type NONE not supported" => {"I" => "lanplus"},

      }

      def self.code
        @@code
      end
    end


  end
end

