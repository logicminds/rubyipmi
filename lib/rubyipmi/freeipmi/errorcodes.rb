module Rubyipmi::Freeipmi
  class ErrorCodes
    CODES = {
      "authentication type unavailable for attempted privilege level" => {"driver-type" => "LAN_2_0"},
      "authentication type unavailable for attempted privilege level\n" => {"driver-type" => "LAN_2_0"}
    }

    def self.length
      CODES.length
    end

    def self.code
      CODES
    end

    def self.search(code)
      # example error code:
      # "/usr/local/sbin/bmc-info: authentication type unavailable for attempted privilege level\n"
      code.chomp! # clean up newline
      code = code.split(':').last.strip # clean up left hand side and strip white space from sides
      fix = CODES.fetch(code, nil)
      if fix.nil?
        CODES.each do |error, result|
          fix = result if code =~ /.*#{error}.*/i
        end
      end
      raise "No Fix found" if fix.nil?
      fix
    end
  end
end
