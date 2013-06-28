require 'rubyipmi/ipmitool/connection'
require 'rubyipmi/freeipmi/connection'
require 'net/smtp'


module Rubyipmi


  # The connect method will create a connection object based the provider type passed in
  # If provider is left blank the function will use the first available provider

    def self.connect(user, pass, host, provider="any",debug=false)

      # use this variable to reduce cmd calls
      installed = false

      # use the first available provider
      if provider == "any"
        if is_provider_installed?("freeipmi")
          provider = "freeipmi"
          installed = true
        elsif is_provider_installed?("ipmitool")
          provider = "ipmitool"
          installed = true
        else
          raise "No IPMI provider is installed, please install freeipmi or ipmitool"
        end
      end

      # If the provider is available create a connection object
      if installed or is_provider_installed?(provider)
        if provider == "freeipmi"
          @conn = Rubyipmi::Freeipmi::Connection.new(user, pass, host, debug=false)
        elsif provider == "ipmitool"
          @conn = Rubyipmi::Ipmitool::Connection.new(user,pass,host, debug=false)
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
    def self.is_provider_installed?(provider)
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

    def self.providers
      ["freeipmi", "ipmitool"]
    end

    # returns true if any of the providers are installed
    def self.provider_installed?
      providers_installed?.length > 0
    end

    def self.providers_installed?
      available = []
      providers.each do |prov|
        if is_provider_installed?(prov)
          available << prov
        end
      end
      return available
    end

    def self.printdiag(user, pass, host)
      @conn = Rubyipmi::connect(user, pass, host)
      puts "Product: #{@conn.fru.product}"
      puts "Manufacturer: #{@conn.fru.manufacturer}"
      puts "BMC Info #{@conn.bmc.info.inspect}\n"
      puts "Please email to corey@logicminds.biz when troubleshooting"
      return true
    end
end
