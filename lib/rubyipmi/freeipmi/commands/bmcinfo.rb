module Rubyipmi::Freeipmi

  class BmcInfo < Rubyipmi::Freeipmi::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("bmc-info", opts)

    end


    def guid
      @options["guid"] = false
      status = runcmd
      @options.delete_notify["guid"]
      if not status
        raise @result
      else
        @result.chomp.strip
      end

    end
    # freeipmi
    # Device ID:         17
    # Device Revision:   1
    #                    [SDR Support]
    # Firmware Revision: 2.09
    #                    [Device Available (normal operation)]
    # IPMI Version:      2.0
    # Additional Device Support:
    #                    [Sensor Device]
    #                    [SDR Repository Device]
    #                    [SEL Device]
    #                    [FRU Inventory Device]
    # Manufacturer ID:   11
    # Product ID:        8192
    # Channel Information:
    #        Channel No: 2
    #       Medium Type: 802.3 LAN
    #     Protocol Type: IPMB-1.0
    #        Channel No: 7
    #       Medium Type: OEM
    #     Protocol Type: KCS
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


