require 'rubyipmi/freeipmi/errorcodes'
require 'rubyipmi/observablehash'

module Rubyipmi::Freeipmi

  class Connection

    attr_accessor :options


    def initialize(user, pass, host)
      @options = Rubyipmi::ObservableHash.new
      raise("Must provide a host to connect to") unless host
      @options["hostname"] = host
      # Credentials can also be stored in the freeipmi configuration file
      # So they are not required
      @options["username"] = user if user
      @options["password"] = pass if pass

      #getWorkArounds
    end

    def provider
        return "freeipmi"
    end

    def bmc
      @bmc ||= Rubyipmi::Freeipmi::Bmc.new(@options)
    end

    def chassis
      @chassis ||= Rubyipmi::Freeipmi::Chassis.new(@options)
    end

  end
end
