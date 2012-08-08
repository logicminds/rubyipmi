module Rubyipmi::Freeipmi

  class Chassis < Rubyipmi::Freeipmi::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmi-chassis", opts)

    end

    # Turn the led light on / off or with a delay
    def identify(status=false, delay=0)
      if status
        if delay <= 0
          options["chassis-identify"] = "FORCE"
        else
          options["chassis-identify"] = delay
        end
      else
        options["chassis-identify"] = "TURN-OFF"
      end
      # Run the command
      value = runcmd
      options.delete_notify("chassis-identify")
      return value
    end

    # Access to the power command created on the fly
    def power
      @power ||= Rubyipmi::Freeipmi::Power.new(@options)
    end

    # Access to the config command created on the fly
    def config
      @config ||= Rubyipmi::Freeipmi::ChassisConfig.new(@options)
    end

    # set boot device from given boot device
    def bootdevice(device, reboot=false, persistent=false)
      if config.bootdevices.include?(device)
        bootstatus = config.bootdevice(device, persistent)
        if reboot and bootstatus
          power.cycle
        end

      else
        raise "Device with name: #{device} is not a valid boot device for host #{options["hostname"]}"
      end
    end

    # set boot device to pxe with option to reboot
    def bootpxe(reboot=false,persistent=false)
      bootstatus = config.bootpxe(persistent)
      # Only reboot if setting the boot flag was successful
      if reboot and bootstatus
        power.cycle
      end
    end

    # set boot device to disk with option to reboot
    def bootdisk(reboot=false,persistent=false)
      bootstatus = config.bootdisk(persistent)
      # Only reboot if setting the boot flag was successful
      if reboot and bootstatus
        power.cycle
      end

    end

    # set boot device to cdrom with option to reboot
    def bootcdrom(reboot=false,persistent=false)
      bootstatus = config.bootcdrom(persistent)
      # Only reboot if setting the boot flag was successful
      if reboot and bootstatus
        power.cycle
      end
    end

    # boot into bios setup with option to reboot
    def bootbios(reboot=false,persistent=false)
      bootstatus = config.bootbios(persistent)
      # Only reboot if setting the boot flag was successful
      if reboot and bootstatus
        power.cycle
      end
    end

    def status
       options["get-status"] = false
       value = runcmd
       options.delete_notify("get-status")
       if value
         return parsestatus
       else
         return value
       end

    end

    # A currently unsupported method to retrieve the led status
    def identifystatus
      # TODO implement this function
      # parse out the identify status
     # status.result
    end

    private
    def parsestatus
      statusresult = @result
      statusvalues = {}
      subkey = nil
      statusresult.lines.each do |line|
        # clean up the data from spaces
        item = line.split(':')
        key = item.first.strip
        value = item.last.strip
        statusvalues[key] = value
      end
      return statusvalues
    end


  end
end