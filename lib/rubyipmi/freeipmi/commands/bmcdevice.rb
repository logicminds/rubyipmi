module Rubyipmi::Freeipmi
  class BmcDevice < Rubyipmi::Freeipmi::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("bmc-device", opts)
    end

    # runs a command like bmc-device --cold-reset
    def command(opt)
      @options[opt] = false
      value = runcmd
      @options.delete_notify(opt)
      return value
    end

    # reset the bmc device, useful for debugging and troubleshooting
    def reset(type = 'cold')
      if ['cold', 'warm'].include?(type)
        key = "#{type}-reset"
        command(key)
      else
        logger.error("reset type: #{type} is not a valid choice, use warm or cold") if logger
        raise "reset type: #{type} is not a valid choice, use warm or cold"
      end
    end
  end
end
