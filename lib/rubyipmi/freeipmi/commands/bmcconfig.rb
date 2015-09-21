module Rubyipmi::Freeipmi
  class BmcConfig < Rubyipmi::Freeipmi::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("bmc-config", opts)
      @sections = []
    end

    def verbose(on = false)
      if on
        @options['verbose'] = false
      else
        @options.delete_notify('verbose')
      end
    end

    def section(section)
      @options["checkout"] = false
      @options["section"] = section
      value = runcmd
      @options.delete_notify("checkout")
      @options.delete_notify("section")
      @result
    end

    def setsection(section, key, value)
      keypair = "#{section}:#{key}=#{value}"
      @options["commit"] = false
      unless keypair.empty?
        @options["key-pair"] = keypair
        value = runcmd
        @options.delete_notify("commit")
        @options.delete_notify("key-pair")
        return value
      end
      false
    end

    # returns the entire bmc-config configuration, can take a while to execute
    def configuration
      @options["checkout"] = false
      value = runcmd
      @options.delete_notify("checkout")
      @result
    end

    # Returns a list of available sections to inspect
    def listsections
      if @sections.length < 1
        @options["listsections"] = false
        value = runcmd
        @options.delete_notify("listsections")
        @sections = @result.split(/\n/) if value
      end
      @sections
    end
  end
end
