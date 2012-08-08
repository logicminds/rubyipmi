module Rubyipmi::Freeipmi

  class ErrorCodes

    @@code = {
        "authentication type unavailable for attempted privilege level" => {"driver-type" => "LAN_2_0"},

    }

    def self.code
       @@code
    end
  end

end
