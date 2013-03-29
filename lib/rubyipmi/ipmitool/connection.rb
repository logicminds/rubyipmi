require 'rubyipmi/ipmitool/errorcodes'
require 'rubyipmi/observablehash'
require 'rubyipmi/commands/basecommand'
require 'rubyipmi/ipmitool/commands/basecommand'

Dir[File.dirname(__FILE__) + '/commands/*.rb'].each do |file|
  require file
end

module Rubyipmi
  module Ipmitool

    class Connection

      attr_accessor :options


      def initialize(user, pass, host)
        @options = Rubyipmi::ObservableHash.new
        raise("Must provide a host to connect to") unless host
        @options["H"] = host
        # Credentials can also be stored in the freeipmi configuration file
        # So they are not required
        @options["U"] = user if user
        @options["P"] = pass if pass
        # default to IPMI 2.0 communication
        #@options["I"] = "lanplus"

        #getWorkArounds
      end

      def fru
        @fru ||= Rubyipmi::Ipmitool::Fru.new(@options)
      end

      def provider
        return "ipmitool"
      end

      def bmc
        @bmc ||= Rubyipmi::Ipmitool::Bmc.new(@options)
      end

      def sensors
        @sensors ||= Rubyipmi::Ipmitool::Sensors.new(@options)
      end

      def chassis
        @chassis ||= Rubyipmi::Ipmitool::Chassis.new(@options)
      end

    end
  end
end
