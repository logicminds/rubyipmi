module Rubyipmi::Ipmitool

  class ChassisConfig < Rubyipmi::Ipmitool::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)

    end

    # Get the current boot device
    def bootdevice
       # Not available with ipmitool
       false
    end

    # Set the boot device
    def bootdevice(device, persistent=false)
      @options["cmdargs"] = "chassis bootdev #{device}"
      value = runcmd
      @options.delete_notify("cmdargs")
      return value
    end

    # Get list of available boot devices
    def bootdevices
      # ideally we should get this list from the ipmidevice
      # However ipmitool only has a static list
      ["pxe", "disk", "safe", "diag", "cdrom", "bios", "floppy"]
    end

    # shortcut to set boot device to pxe
    def bootpxe(persistent=false)
      bootdevice("pxe")
    end

    # shortcut to set boot device to disk
    def bootdisk(persistent=false)
      bootdevice("disk")
    end

    # shortcut to set boot device to cdrom
    def bootcdrom(persistent=false)
      bootdevice("cdrom")
    end

    # shortcut to boot into bios setup
    def bootbios(persistent=false)
      bootdevice("bios")
    end

  end
end