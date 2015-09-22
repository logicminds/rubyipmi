require 'rubyipmi/commands/mixins/power_mixin'

module Rubyipmi::Freeipmi
  class Power < Rubyipmi::Freeipmi::BaseCommand
    include Rubyipmi::PowerMixin

    def initialize(opts = ObservableHash.new)
      super("ipmipower", opts)
    end

    # The command function is a wrapper that actually calls the run method
    def command(opt)
      @options[opt] = false
      runcmd
      @options.delete_notify(opt)
      @result
    end

    def power_interrupt
      command("pulse")
    end

    # Get the power status of the system, will show either on or off
    def status
      value = command("stat")
      @result.split(":").last.chomp.strip if value
    end
  end
end
