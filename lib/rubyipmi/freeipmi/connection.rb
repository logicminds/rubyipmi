require 'rubyipmi/freeipmi/errorcodes'
require 'rubyipmi/observablehash'
require 'rubyipmi/commands/basecommand'
require 'rubyipmi/freeipmi/commands/basecommand'

Dir[File.dirname(__FILE__) + '/commands/*.rb'].each do |file|
  require file
end
module Rubyipmi
  module Freeipmi
    class Connection
      attr_accessor :options

      def initialize(user, pass, host, opts)
        @options = Rubyipmi::ObservableHash.new
        raise("Must provide a host to connect to") unless host
        @options["hostname"] = host
        # Credentials can also be stored in the freeipmi configuration file
        # So they are not required
        @options["username"] = user if user
        @options["password"] = pass if pass
        if opts.has_key?(:privilege)
          @options["privilege-level"] = opts[:privilege]        # privilege type
        end
        # Note: rubyipmi should auto detect which driver to use so its unnecessary to specify the driver unless
        #       the user really wants to
        @options['driver-type'] = drivers_map[opts[:driver]] unless drivers_map[opts[:driver]].nil?
      end

      # test the connection to ensure we can at least make a single call
      def connection_works?
        begin
          ! (bmc.info.nil? || bmc.info.empty? )
        rescue
          false
        end
      end

      def drivers_map
        {
          'lan15' => 'LAN',
          'lan20' => 'LAN_2_0',
          'open'  => 'OPENIPMI'
        }
      end

      def provider
        'freeipmi'
      end

      def fru
        @fru ||= Rubyipmi::Freeipmi::Fru.new(@options)
      end

      def bmc
        @bmc ||= Rubyipmi::Freeipmi::Bmc.new(@options)
      end

      def chassis
        @chassis ||= Rubyipmi::Freeipmi::Chassis.new(@options)
      end

      def sensors
        @sensors ||= Rubyipmi::Freeipmi::Sensors.new(@options)
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