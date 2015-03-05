# Copyright (C) 2014 Corey Osman
#
#     This library is free software; you can redistribute it and/or
#     modify it under the terms of the GNU Lesser General Public
#     License as published by the Free Software Foundation; either
#     version 2.1 of the License, or (at your option) any later version.
#
#     This library is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public
#     License along with this library; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
#     USA
#


require 'rubyipmi/ipmitool/connection'
require 'rubyipmi/freeipmi/connection'


module Rubyipmi
  PRIV_TYPES = ['CALLBACK', 'USER', 'OPERATOR', 'ADMINISTRATOR']

  def self.valid_drivers
    ['auto', "lan15", "lan20", "open"]
  end

  def self.valid_providers
    ['auto', 'ipmitool', 'freeipmi']
  end
  # The connect method will create a connection object based the provider type passed in
  # If provider is left blank the function will use the first available provider
  # When the driver is set to auto, rubyipmi will try and figure out which driver to use by common error messages.  We will most likely be using
  # the lan20 driver, but in order to support a wide use case we default to auto.
  def self.connect(user, pass, host, provider='any', opts={:driver => 'auto', :timeout => 'default', :debug => false})
    # use this variable to reduce cmd calls
    installed = false

    # allow the user to specify an options hash instead of the provider
    # in the future I would stop using the provider and use the opts hash instead to get the provider
    # This allows us to be a little more flexible if the user is doesn't supply us what we need.
    if provider.is_a?(Hash)
      opts = provider
      provider = opts[:provider] ||= 'any'
    end

    # Verify options just in case user passed in a incomplete hash
    opts[:driver]  ||= 'auto'
    opts[:timeout] ||= 'default'
    opts[:debug]   = false if opts[:debug] != true

    if opts[:privilege] and not supported_privilege_type?(opts[:privilege])
      raise "Invalid privilege type :#{opts[:privilege]}, must be one of: #{PRIV_TYPES.join("\n")}"
    end

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
        raise "Incorrect provider given, must use one of #{valid_providers.join(', ')}"
      end
    else
      # Can't find the provider command line tool, maybe try other provider?
      raise "The IPMI provider: #{provider} is not installed"
    end
  end

  # returns boolean true if privilege type is valid
  def self.supported_privilege_type?(type)
     PRIV_TYPES.include?(type)
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
  def self.get_diag(user, pass, host, provider='any', opts={:driver => 'auto', :timeout => 'default', :debug => false})
    data = {}
    if Rubyipmi.is_provider_installed?('freeipmi')
      freeconn = Rubyipmi.connect(user, pass, host, 'freeipmi', opts)
      if freeconn
        puts "Retrieving freeipmi data"
        data[:freeipmi] = freeconn.get_diag
      end
    end
    if Rubyipmi.is_provider_installed?('ipmitool')
      ipmiconn = Rubyipmi.connect(user, pass, host, 'ipmitool', opts)
      if ipmiconn
        puts "Retrieving ipmitool data"
        data[:ipmitool] = ipmiconn.get_diag
      end
    end
    File.open('/tmp/rubyipmi_diag_data.txt', 'w') {|f| f.write(data)}
    puts "Created file /tmp/rubyipmi_diag_data.txt"
  end
end
