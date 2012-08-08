require 'rubyipmi/ipmitool/connection'
require 'rubyipmi/freeipmi/connection'

module Rubyipmi


  # The connect method will create a connection object based the provider type passed in
  # If provider is left blank the function will use the first available provider

    def self.connect(user, pass, host, provider="any")

      # use the first available provider
      if provider == "any"
        if is_provider_present?("freeipmi")
          provider = "freeipmi"
        elsif is_provider_present?("ipmitool")
          provider = "ipmitool"
        else
          raise "No IPMI provider is installed, please install freeipmi or ipmitool"
        end
      end

      # If the provider is available create a connection object
      if is_provider_present?(provider)
        if provider == "freeipmi"
          @conn = Rubyipmi::Freeipmi::Connection.new(user, pass, host)
        elsif provider == "ipmitool"
          @conn = Rubyipmi::Ipmitool::Connection.new(user,pass,host)
        else
          raise "Incorrect provider given, must use freeipmi or ipmitool"
        end
      else
        # Can't find the provider command line tool, maybe try other provider?
        raise "The IPMI provider: #{provider} is not installed"

      end
    end

    def self.connection
      return @conn if @conn
      raise "No Connection available, please use the connect method"
    end

    # Return true or false if the provider is available
    def self.is_provider_present?(provider)
      case provider
        when "freeipmi"
          cmdpath = `which ipmipower`.strip
        when "ipmitool"
          cmdpath = `which ipmitool`.strip
        else
          raise "Invalid BMC provider type"
      end
      return $?.success?
    end

  end
