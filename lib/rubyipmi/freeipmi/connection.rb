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

    end
  end
end
