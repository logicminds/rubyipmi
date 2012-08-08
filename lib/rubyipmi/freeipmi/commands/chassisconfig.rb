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
      return value
    end

    # This is the raw command to get the entire ipmi chassis configuration
    # If you pass in a section you will get just the section
    def checkout(section=nil)
      @options["checkout"] = false
      if section
        @options["section"] = section
      end
      value = runcmd
      @options.delete_notify("checkout")
      if section
        @options.delete_notify("section")
      end
      return value
    end

    def bootdevice
      value = checkout("Chassis_Boot_Flags")
      if value
        # TODO parse result to return current boot device
        #@result
      end
    end

    def bootdevice(device, persistent=false)
      setBootFlag("Boot_Device", device)
    end

    def bootdevices
      # freeipmi returns a list of supported devices
      # However, for now we will just assume the following
      ["PXE", "HARD-DRIVE", "CD-DVD", "BIOS-SETUP"]
      # TODO return array of possible boot devices
    end

    def bootpersistent(value)
      # TODO find out if we can specify multiple key-pair values
      if value == true
        flag = "Chassis_Boot_Flags:Boot_Flags_Persistent=Yes"
      else
        flag = "Chassis_Boot_Flags:Boot_Flags_Persistent=No"
      end
      @options["key-pair"] = "\"#{flag}\""
      value = commit
      @options.delete_notify("key-pair")
      return value
    end



    # shortcut to set boot device to pxe
    def bootpxe(persistent=false)
      bootdevice = "PXE"
    end

    # shortcut to set boot device to disk
    def bootdisk(persistent=false)
      bootdevice = "HARD-DRIVE"
    end

    # shortcut to set boot device to cdrom
    def bootcdrom(persistent=false)
      bootdevice = "CD-DVD"
    end

    # shortcut to boot into bios setup
    def bootbios(persistent=false)
      bootdevice = "BIOS-SETUP"
    end

    private

    def setBootFlag(key,flag, persistent=false)
      @options["key-pair"] = "\"Chassis_Boot_Flags:#{key}=#{flag}\""
      value = commit
      @options.delete_notify("key-pair")
      return value
    end
  end

   ## Possible values: NO-OVERRIDE/PXE/HARD-DRIVE/HARD-DRIVE-SAFE-MODE/
   ##                  DIAGNOSTIC_PARTITION/CD-DVD/BIOS-SETUP/REMOTE-FLOPPY
   ##                  PRIMARY-REMOTE-MEDIA/REMOTE-CD-DVD/REMOTE-HARD-DRIVE/FLOPPY
end