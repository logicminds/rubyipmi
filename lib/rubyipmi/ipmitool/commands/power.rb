# frozen_string_literal: true

require 'rubyipmi/commands/mixins/power_mixin'

module Rubyipmi::Ipmitool
  class Power < Rubyipmi::Ipmitool::BaseCommand
    include Rubyipmi::PowerMixin

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
    end

    # The command function is a wrapper that actually calls the run method
    def command(opt)
      @options["cmdargs"] = "power #{opt}"
      value = runcmd
      @options.delete_notify("cmdargs")
      value
    end

    def power_interrupt
      command("diag")
    end

    # Get the power status of the system, will show either on or off
    def status
      value = command("status")
      @result.match(/(off|on)/).to_s if value
    end
  end
end
