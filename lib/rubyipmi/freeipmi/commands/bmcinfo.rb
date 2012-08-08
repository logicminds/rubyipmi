module Rubyipmi::Freeipmi

  class BmcInfo < Rubyipmi::Freeipmi::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("bmc-info", opts)
    end

    def retrieve
      status = runcmd
      if not status
        raise @result
      else
        @result
      end
    end

  end
end


