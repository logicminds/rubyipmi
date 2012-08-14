module Rubyipmi::Freeipmi

  class Bmc

    attr_accessor :options

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

    def lan
      @lan ||= Rubyipmi::Freeipmi::Lan.new(@options)
    end

    def information
      @info ||= Rubyipmi::Freeipmi::BmcInfo.new(@options)
    end
  end
end
