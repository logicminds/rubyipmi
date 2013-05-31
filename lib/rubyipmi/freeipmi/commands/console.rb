module Rubyipmi::Freeipmi

  class Console < Rubyipmi::Freeipmi::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmiconsole", opts)

    end

    def activate
      # no option is require to activate
      value = runcmd
      return value
    end

    def deactivate
      @options["deactivate"] = false
      value = runcmd
      @options.delete_notify("deactivate")
      return value
    end

  end

end