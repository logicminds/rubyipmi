module Rubyipmi::Freeipmi
  class Power < Rubyipmi::Freeipmi::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("ipmipower", opts)
    end

    # The command function is a wrapper that actually calls the run method
    def command(opt)
      @options[opt] = false
      value = runcmd
      @options.delete_notify(opt)
      @result
    end

    # Turn on the system
    def on
      command("on")
    end

    # Turn off the system
    def off
      command("off")
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
      command("pulse")
    end

    # Get the power status of the system, will show either on or off
    def status
      value = command("stat")
      @result.split(":").last.chomp.strip if value
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
