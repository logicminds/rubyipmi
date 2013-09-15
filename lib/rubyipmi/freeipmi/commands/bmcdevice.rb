module Rubyipmi::Freeipmi

  class BmcDevice < Rubyipmi::Freeipmi::BaseCommand

    def initialize(opts = Hash.new)
      super("bmc-device", opts)
    end

    # runs a command like bmc-device --cold-reset
    def command(opt)
      @options[opt] = false
      value = runcmd
      @options.delete(opt)
      return value
    end

    # reset the bmc device, useful for debugging and troubleshooting
    def reset(type='cold')
      if ['cold', 'warm'].include?(type)
        key = "#{type}-reset"
        command(key)
      else
        raise "reset type: #{type} is not a valid choice, use warm or cold"
      end
    end



  end


end
