require 'rubyipmi/ipmitool/connection'
require 'rubyipmi/freeipmi/connection'


module Rubyipmi


  def self.valid_drivers
    ['auto', "lan15", "lan20", "open"]
  end

  # The connect method will create a connection object based the provider type passed in
  # If provider is left blank the function will use the first available provider

  def self.connect(user, pass, host, provider='any', opts={:driver => 'auto', :timeout => 'default', :debug => false})

    # use this variable to reduce cmd calls
    installed = false

    if provider.is_a?(Hash)
      opts = provider
      provider = 'any'
    end

    # Verify options just in case user passed in a incomplete hash
    opts[:driver]  = 'auto' if opts[:driver].nil?
    opts[:timeout] = 'default' if opts[:timeout].nil?
    opts[:debug]   = false if opts[:debug] != true

    # use the first available provider
    if provider == 'any'
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

    # Support multiple drivers
    # Note: these are just generic names of drivers that need to be specified for each provider
    unless valid_drivers.include?(opts[:driver])
      raise "You must specify a valid driver: #{valid_drivers.join(',')}"
    end

    # If the provider is available create a connection object
    if installed or is_provider_installed?(provider)
      if provider == "freeipmi"
        @conn = Rubyipmi::Freeipmi::Connection.new(user, pass, host, opts)
      elsif provider == "ipmitool"
        @conn = Rubyipmi::Ipmitool::Connection.new(user,pass,host, opts)
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

  # method used to find the command which also makes it easier to mock with
  def self.locate_command(commandname)
    location = `which #{commandname}`.strip
    if not $?.success?
      location = nil
    end
    return location
  end

  # Return true or false if the provider is available
  def self.is_provider_installed?(provider)
    case provider
      when "freeipmi"
        cmdpath = locate_command('ipmipower')
      when "ipmitool"
        cmdpath = locate_command('ipmitool')
      else
        raise "Invalid BMC provider type"
    end
    # return false if command was not found
    return ! cmdpath.nil?
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

  # gets data from the bmc device and puts in a hash for diagnostics
  def self.get_diag(user, pass, host)
    data = {}

    if Rubyipmi.is_provider_installed?('freeipmi')
      @freeconn = Rubyipmi::connect(user, pass, host, 'freeipmi')
      if @freeconn
        puts "Retrieving freeipmi data"
        data['freeipmi'] = @freeconn.get_diag
      end
    end
    if Rubyipmi.is_provider_installed?('ipmitool')
      @ipmiconn = Rubyipmi::connect(user, pass, host, 'ipmitool')
      if @ipmiconn
        puts "Retrieving ipmitool data"
        data['ipmitool'] = @ipmiconn.get_diag
      end
    end
    return data
  end

end
