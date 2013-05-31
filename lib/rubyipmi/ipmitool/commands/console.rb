module Rubyipmi::Ipmitool

  class Console < Rubyipmi::Ipmitool::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)

    end


    def activate
      # Set the command line arguments  (-I lanplus is already handled for you)
      @options["cmdargs"] = "sol activate"
      value = runcmd
      @options.delete_notify("cmdargs")
      return value
    end

    def deactivate
      # Set the command line arguments  (-I lanplus is already handled for you)
      @options["cmdargs"] = "sol deactivate"
      value = runcmd
      @options.delete_notify("cmdargs")
      return value
    end



  end


end

