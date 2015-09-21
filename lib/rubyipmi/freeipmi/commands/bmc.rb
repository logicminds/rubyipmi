module Rubyipmi::Freeipmi
  class Bmc < Rubyipmi::Freeipmi::BaseCommand

    # attr_accessor :options
    attr_accessor :config

    def initialize(opts = ObservableHash.new)
      super("bmc-device", opts)
      @bmcinfo = {}
    end

    def version
      @options['version'] = false
      value = runcmd
      @options.delete_notify('version')
      @result.slice(/\d\.\d.\d/)
    end

    def info
      if @bmcinfo.length > 0
        @bmcinfo
      else
        information.retrieve
      end
    end

    def reset(type = 'cold')
      device.reset(type)
    end

    def guid
      information.guid
    end

    def config
      @config ||= Rubyipmi::Freeipmi::BmcConfig.new(options)
    end

    def lan
      @lan ||= Rubyipmi::Freeipmi::Lan.new(options)
    end

    def information
      @info ||= Rubyipmi::Freeipmi::BmcInfo.new(options)
    end

    def device
      @bmcdevice ||= Rubyipmi::Freeipmi::BmcDevice.new(options)
    end
  end
end
