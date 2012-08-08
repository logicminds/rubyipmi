module Rubyipmi::Ipmitool

  class BmcInfo < Rubyipmi::Ipmitool::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
    end
   # Some sample data
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


    def retrieve
      @options["cmdargs"] = "bmc info"
      status = runcmd
      @options.delete_notify("cmdargs")
      if not status
        raise @result
      else
        @result
      end
    end

  end
end


