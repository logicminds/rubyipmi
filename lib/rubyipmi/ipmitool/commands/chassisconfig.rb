# frozen_string_literal: true

module Rubyipmi::Ipmitool
  class ChassisConfig < Rubyipmi::Ipmitool::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
    end

    # Set the boot device
    def bootdevice(device, persistent = false)
      @options["cmdargs"] = if persistent
                              "chassis bootdev #{device}"
                            else
                              "chassis bootparam set bootflag force_#{device}"
                            end
      value = runcmd
      @options.delete_notify("cmdargs")
      value
    end

    # Get list of available boot devices
    def bootdevices
      # ideally we should get this list from the ipmidevice
      # However ipmitool only has a static list
      ["pxe", "disk", "safe", "diag", "cdrom", "bios", "floppy"]
    end

    # shortcut to set boot device to pxe
    def bootpxe(persistent = true)
      bootdevice("pxe", persistent)
    end

    # shortcut to set boot device to disk
    def bootdisk(persistent = true)
      bootdevice("disk", persistent)
    end

    # shortcut to set boot device to cdrom
    def bootcdrom(persistent = true)
      bootdevice("cdrom", persistent)
    end

    # shortcut to boot into bios setup
    def bootbios(persistent = true)
      bootdevice("bios", persistent)
    end
  end
end
