module Rubyipmi::Ipmitool
  class Power < Rubyipmi::Ipmitool::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
    end

    # The command function is a wrapper that actually calls the run method
    def command(opt)
      @options["cmdargs"] = "power #{opt}"
      value = runcmd
      @options.delete_notify("cmdargs")
      return value
    end

    # Turn on the system
    def on
      if on?
        return true
      else
        command("on")
      end
    end

    # Turn off the system
    def off
      if off?
        return true
      else
        command("off")
      end
    end

    # Power cycle the system
    def cycle
      # if the system is off turn it on
      if off?
        on
      else
        command("cycle")
      end
    end

    # Perform a power reset on the system
    def reset
      command("reset")
    end

    # Perform a soft shutdown, like briefly pushing the power button
    def softShutdown
      command("soft")
    end

    def powerInterrupt
      command("diag")
    end

    # Get the power status of the system, will show either on or off
    def status
      value = command("status")
      @result.match(/(off|on)/).to_s if value
    end

    # Test to see if the power is on
    def on?
      status == "on"
    end

    # Test to see if the power is off
    def off?
      status == "off"
    end
  end
end
