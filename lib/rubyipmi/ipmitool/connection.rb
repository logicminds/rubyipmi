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

      attr_accessor :options, :debug
      attr_reader :debug


      def initialize(user, pass, host, debug_value=false, opts)
        @debug = debug_value
        @options = Rubyipmi::ObservableHash.new
        raise("Must provide a host to connect to") unless host
        @options["H"] = host
        # Credentials can also be stored in the freeipmi configuration file
        # So they are not required
        @options["U"] = user if user
        @options["P"] = pass if pass
        # default to IPMI 2.0 communication, this means that older devices will not work
        # Those old servers should be recycled by now, as the 1.0, 1.5 spec came out in 2005ish and is 2013.
        @options["I"] = "lan"     if opts[:driver] == "lan15"
        @options["I"] = "lanplus" if opts[:driver] == "lan20"
        @options["I"] = "open"    if opts[:driver] == "open"

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

      def get_diag
        data = {}
        data['provider'] = provider
        if @fru
          data['frus'] = @fru.getfrus
        end
        if @sensors
          data['sensors'] = @sensors.getsensors
        end
        if @bmc
          data['bmc_info'] = @bmc.info
        end
      end

    end
  end
end
