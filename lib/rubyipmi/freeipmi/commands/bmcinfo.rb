module Rubyipmi::Freeipmi

  class BmcInfo < Rubyipmi::Freeipmi::BaseCommand

    def initialize(opts = Hash.new)
      super("bmc-info", opts)

    end


    def guid
      options["get-device-guid"] = false
      status = runcmd
      options.delete("get-device-guid")
      if not status
        raise @result
      else
        @result.chomp.strip
      end

    end

    def retrieve
      bmcinfo = {}
      status = runcmd
      subkey = nil
      if not status
        raise @result
      else
        @result.lines.each do |line|
          # clean up the data from spaces
          item = line.split(':')
          key = item.first.strip
          value = item.last.strip
          # if the following condition is met we have subvalues
          if key == value and not subkey
            subkey = key
            bmcinfo[subkey] = []
          elsif key == value and subkey
            # subvalue found
            bmcinfo[subkey] << value.gsub(/\[|\]/, "")
          else
            # Normal key/value pair with no subkeys
            subkey = nil
            bmcinfo[key] = value
          end
        end
        return bmcinfo
      end
    end


  end
end


