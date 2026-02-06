module Rubyipmi::Ipmitool
  class Chassis < Rubyipmi::Ipmitool::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
    end

    # Turn the led light on / off or with a delay
    # status means to enable or disable the blinking
    def identify(status = false, delay = 0)
      if status
        if !delay.between?(1, 255)
          options["cmdargs"] = "chassis identify 255"
        else
          options["cmdargs"] = "chassis identify #{delay}"
        end
      else
        options["cmdargs"] = "chassis identify 0"
      end
      # Run the command
      value = runcmd
      options.delete_notify("cmdargs")
      value
    end

    # Access to the power command created on the fly
    def power
      @power ||= Rubyipmi::Ipmitool::Power.new(@options)
    end

    # Access to the config command created on the fly
    def config
      @config ||= Rubyipmi::Ipmitool::ChassisConfig.new(@options)
    end

    # set boot device from given boot device
    def bootdevice(device, reboot = false, persistent = false)
      if config.bootdevices.include?(device)
        bootstatus = config.bootdevice(device, persistent)
        power.cycle if reboot && status
      else
        logger&.debug("Device with name: #{device} is not a valid boot device for host #{options['hostname']}")
        raise "Device with name: #{device} is not a valid boot device for host #{options['hostname']}"
      end
      bootstatus
    end

    # set boot device to pxe with option to reboot
    def bootpxe(reboot = false, persistent = false)
      bootstatus = config.bootpxe(persistent)
      # Only reboot if setting the boot flag was successful
      power.cycle if reboot && bootstatus
      bootstatus
    end

    # set boot device to disk with option to reboot
    def bootdisk(reboot = false, persistent = false)
      bootstatus = config.bootdisk(persistent)
      # Only reboot if setting the boot flag was successful
      power.cycle if reboot && bootstatus
      bootstatus
    end

    # set boot device to cdrom with option to reboot
    def bootcdrom(reboot = false, persistent = false)
      bootstatus = config.bootcdrom(persistent)
      # Only reboot if setting the boot flag was successful
      power.cycle if reboot && bootstatus
      bootstatus
    end

    # boot into bios setup with option to reboot
    def bootbios(reboot = false, persistent = false)
      bootstatus = config.bootbios(persistent)
      # Only reboot if setting the boot flag was successful
      power.cycle if reboot && bootstatus
      bootstatus
    end

    def status
      options["cmdargs"] = "chassis status"
      value = runcmd
      options.delete_notify("cmdargs")
      {:result => @result, :value => value}
    end

    # A currently unsupported method to retrieve the led status
    def identifystatus
      options["cmdargs"] = "chassis identify status"
      value = runcmd
      options.delete_notify("cmdargs")
      @result.chomp.split(":").last.strip if value
    end
  end
end
