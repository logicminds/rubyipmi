module Rubyipmi::Freeipmi

  class ErrorCodes

    @@codes = {
        "authentication type unavailable for attempted privilege level" => {"driver-type" => "LAN_2_0"},

    }

    def self.length
      @@codes.length
    end

    def self.code
       @@codes
    end

    def self.search(code)
      fix = @@codes.fetch(code,nil)
      if fix.nil?
        @@codes.each do | error, result |
          if error =~ /^#{Regexp.escape(code)}.*/i
            return result
          end
        end
      else
        return fix
      end
      raise "No Fix found" if fix.nil?
    end

  end

end
