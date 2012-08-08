module Rubyipmi::Freeipmi

  class Bmc

    attr_accessor :options

    def initialize(opts = ObservableHash.new)
      @options = opts
    end

    def guid

    end

    def info
      @info ||= Rubyipmi::Freeipmi::BmcInfo.new(@options)
    end
  end
end
