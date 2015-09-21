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

      DRIVERS_MAP = {
        'lan15' => 'lan',
        'lan20' => 'lanplus',
        'open'  => 'open'
      }

      def initialize(user, pass, host, opts)
        @options = Rubyipmi::ObservableHash.new
        raise("Must provide a host to connect to") unless host
        @options["H"] = host
        # Credentials can also be stored in the freeipmi configuration file
        # So they are not required
        @options["U"] = user if user
        @options["P"] = pass if pass
        @options["L"] = opts[:privilege] if opts.has_key?(:privilege)
        # Note: rubyipmi should auto detect which driver to use so its unnecessary to specify the driver unless
        #  the user really wants to.
        @options['I'] = DRIVERS_MAP[opts[:driver]] unless DRIVERS_MAP[opts[:driver]].nil?
      end

      # test the connection to ensure we can at least make a single call
      def connection_works?
        begin
          ! (bmc.info.nil? || bmc.info.empty? )
        rescue
          false
        end
      end

      def fru
        @fru ||= Rubyipmi::Ipmitool::Fru.new(@options)
      end

      def provider
        'ipmitool'
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
        data[:provider] = provider
        data[:frus]     = fru.getfrus
        data[:sensors]  = sensors.getsensors
        data[:bmc_info] = bmc.info
        data[:version]  = bmc.version
        data
      end
    end
  end
end
