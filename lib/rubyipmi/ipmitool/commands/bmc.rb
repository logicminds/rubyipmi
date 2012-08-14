module Rubyipmi::Ipmitool

  class Bmc < Rubyipmi::Ipmitool::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
      @bmcinfo = {}
    end


    def lan
      @lan ||= Rubyipmi::Ipmitool::Lan.new(@options)
    end

    def info
      if @bmcinfo.length > 0
        @bmcinfo
      else
        retrieve
      end
    end

    def guid
      @options["cmdargs"] = "bmc guid"
      value = runcmd()
      @options.delete_notify("cmdargs")
      if value
        @result.lines.each { | line |
          line.chomp
          if line =~ /GUID/
            line.split(":").last.strip
          end
        }
      end

    end

    # Some sample data for info
    # Device ID                 : 17
    # Device Revision           : 1
    # Firmware Revision         : 2.9
    # IPMI Version              : 2.0
    # Manufacturer ID           : 11
    # Manufacturer Name         : Hewlett-Packard
    # Product ID                : 8192 (0x2000)
    # Product Name              : Unknown (0x2000)
    # Device Available          : yes
    # Provides Device SDRs      : yes
    # Additional Device Support :
    #     Sensor Device
    #     SDR Repository Device
    #     SEL Device
    #     FRU Inventory Device
    # Aux Firmware Rev Info     :
    #     0x00
    #     0x00
    #     0x00
    #     0x30


    # This function will get the bmcinfo and return a hash of each item in the info
    def retrieve
      @options["cmdargs"] = "bmc info"
      status = runcmd
      @options.delete_notify("cmdargs")
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
            @bmcinfo[subkey] = []
          elsif key == value and subkey
            # subvalue found
            @bmcinfo[subkey] << value
          else
            # Normal key/value pair with no subkeys
            subkey = nil
            @bmcinfo[key] = value
          end
        end
        return @bmcinfo
      end
    end


  end
end
