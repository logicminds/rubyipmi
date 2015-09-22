module Rubyipmi
  module PowerMixin
    # Turn the system on
    def on
      command("on")
    end

    # Turn the system off
    def off
      command("off")
    end

    # Perform a power reset on the system
    def reset
      command("reset")
    end

    # Power cycle the system
    def cycle
      off? ? on : command("cycle")
    end

    # Perform a soft shutdown, like briefly pushing the power button
    def soft_shutdown
      command("soft")
    end

    # Test to see if the power is on
    def on?
      status == "on"
    end

    # Test to see if the power is off
    def off?
      status == "off"
    end

    # DEPRECATED: Please use soft_shutdown instead.
    def softShutdown
      warn "[DEPRECATION] `softShutdown` is deprecated, please use `soft_shutdown` instead."
      soft_shutdown
    end

    # DEPRECATED: Please use power_interrupt instead.
    def powerInterrupt
      warn "[DEPRECATION] `powerInterrupt` is deprecated, please use `power_interrupt` instead."
      power_interrupt
    end
  end
end
