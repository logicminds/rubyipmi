module Rubyipmi::Freeipmi
  class ChassisConfig < Rubyipmi::Freeipmi::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("ipmi-chassis-config", opts)
    end

    # This is the raw command to send a new configuration to the ipmi device
    def commit
      @options["commit"] = false
      value = runcmd
      @options.delete_notify("commit")
      value
    end

    # This is the raw command to get the entire ipmi chassis configuration
    # If you pass in a section you will get just the section
    def checkout(section = nil)
      @options["checkout"] = false
      @options["section"] = section if section
      value = runcmd
      @options.delete_notify("checkout")
      @options.delete_notify("section") if section
      value
    end

    def bootdevice(device, persistent)
      set_boot_flag("Boot_Device", device, persistent)
    end

    def bootdevices
      # freeipmi returns a list of supported devices
      # However, for now we will just assume the following
      ["PXE", "HARD-DRIVE", "CD-DVD", "BIOS-SETUP"]
      # TODO: return array of possible boot devices
    end

    def bootpersistent(value)
      # TODO: find out if we can specify multiple key-pair values
      if value == true
        flag = "Chassis_Boot_Flags:Boot_Flags_Persistent=Yes"
      else
        flag = "Chassis_Boot_Flags:Boot_Flags_Persistent=No"
      end
      @options["key-pair"] = "\"#{flag}\""
      value = commit
      @options.delete_notify("key-pair")
      value
    end

    # shortcut to set boot device to pxe
    def bootpxe(persistent = true)
      bootdevice("PXE", persistent)
    end

    # shortcut to set boot device to disk
    def bootdisk(persistent = true)
      bootdevice("HARD-DRIVE", persistent)
    end

    # shortcut to set boot device to cdrom
    def bootcdrom(persistent = true)
      bootdevice("CD-DVD", persistent)
    end

    # shortcut to boot into bios setup
    def bootbios(persistent = true)
      bootdevice("BIOS-SETUP", persistent)
    end

    private

    def set_boot_flag(key, flag, _persistent)
      @options["key-pair"] = "\"Chassis_Boot_Flags:#{key}=#{flag}\""
      value = commit
      @options.delete_notify("key-pair")
      value
    end
  end

  ## Possible values: NO-OVERRIDE/PXE/HARD-DRIVE/HARD-DRIVE-SAFE-MODE/
  ##                  DIAGNOSTIC_PARTITION/CD-DVD/BIOS-SETUP/REMOTE-FLOPPY
  ##                  PRIMARY-REMOTE-MEDIA/REMOTE-CD-DVD/REMOTE-HARD-DRIVE/FLOPPY
end
