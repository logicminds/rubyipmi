module Rubyipmi::Freeipmi

  class Bmc

    attr_accessor :options
    attr_accessor :config

    def initialize(opts = ObservableHash.new)
      @options = opts
      @bmcinfo = {}
    end

    def info
      if @bmcinfo.length > 0
        @bmcinfo
      else
        information.retrieve
      end
    end

    def guid
       information.guid
    end

    def config
      @config ||= Rubyipmi::Freeipmi::BmcConfig.new(opts)
    end

    def lan
      @lan ||= Rubyipmi::Freeipmi::Lan.new(config)
    end

    def information
      @info ||= Rubyipmi::Freeipmi::BmcInfo.new(@options)
    end
  end
end
