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
      @@codes.each do | error, fix |
        if code =~ /^#{Regexp.escape(error)}/i
          return fix
        end
      end
      raise "No Fix found"

    end

  end

end
