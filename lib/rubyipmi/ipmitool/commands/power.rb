module Rubyipmi::Ipmitool

  class Power < Rubyipmi::Ipmitool::BaseCommand

    def initialize(opts = Hash.new)
      super("ipmitool", opts)
    end

    # The command function is a wrapper that actually calls the run method
    def command(opt)
      @options["cmdargs"] = "power #{opt}"
      value = runcmd
      @options.delete("cmdargs")
      return value
    end

    # Turn on the system
    def on
      if off?
        command("on")
      else
         return true
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
      if value
        @result.match(/(off|on)/).to_s
      end
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
