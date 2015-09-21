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
require 'logger'

class NullLogger < Logger
  def initialize(*args)
  end

  def add(*args, &block)
  end
end

module Rubyipmi
  PRIV_TYPES = ['CALLBACK', 'USER', 'OPERATOR', 'ADMINISTRATOR']
  attr_accessor :logger, :log_level

  # set a logger instance yourself to customize where the logs should go
  # you will need to set the log level yourself
  def self.logger=(log)
    @logger = log
  end

  # sets the log level, this should be called first if logging to a file is desired
  # if you wish to customize the logging options, set the logger yourself with logger=
  # valid levels are of the type Logger::INFO, Logger::DEBUG, Logger::ERROR, ...
  def self.log_level=(level)
    @log_level = level
  end

  # this is an read only method that only creates a real logger if the log_level is set
  # if the log_level is not setup it creates a null logger which logs nothing
  def self.logger
    # by default the log will be set to info
    unless @logger
      if @log_level and @log_level >= 0
        @logger = Logger.new('/tmp/rubyipmi.log')
        @logger.progname = 'Rubyipmi'
        @logger.level = @log_level
      else
        @logger = NullLogger.new
      end
    end
    @logger
  end

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
  def self.connect(user, pass, host, provider = 'any', opts = {:driver => 'lan20', :timeout => 'default'})
    # use this variable to reduce cmd calls
    installed = false

    # if the user supplied nil, we want to fix this automatically
    opts = {:driver => 'lan20', :timeout => 'default'} if opts.nil?

    # convert all keys to symbols for opts, we can't assume the user will use symbols
    opts.keys.each do |key|
      opts[(key.to_sym rescue key) || key] = opts.delete(key)
    end

    # allow the user to specify an options hash instead of the provider
    # in the future I would stop using the provider and use the opts hash instead to get the provider
    # This allows us to be a little more flexible if the user is doesn't supply us what we need.
    if provider.kind_of?(Hash)
      opts = provider
      provider = opts[:provider] ||= 'any'
    end

    # Verify options just in case user passed in a incomplete hash
    opts[:driver] ||= 'lan20'
    opts[:timeout] ||= 'default'

    if opts[:privilege] and !supported_privilege_type?(opts[:privilege])
      logger.error("Invalid privilege type :#{opts[:privilege]}, must be one of: #{PRIV_TYPES.join("\n")}") if logger
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
        logger.error("No IPMI provider is installed, please install freeipmi or ipmitool")
        raise "No IPMI provider is installed, please install freeipmi or ipmitool"
      end
    end

    # Support multiple drivers
    # Note: these are just generic names of drivers that need to be specified for each provider
    unless valid_drivers.include?(opts[:driver])
      logger.debug("You must specify a valid driver: #{valid_drivers.join(',')}") if logger
      raise "You must specify a valid driver: #{valid_drivers.join(',')}"
    end

    # If the provider is available create a connection object
    if installed or is_provider_installed?(provider)
      if provider == "freeipmi"
        Rubyipmi::Freeipmi::Connection.new(user, pass, host, opts)
      elsif provider == "ipmitool"
        Rubyipmi::Ipmitool::Connection.new(user, pass, host, opts)
      else
        logger.error("Incorrect provider given, must use one of #{valid_providers.join(', ')}") if logger
        raise "Incorrect provider given, must use one of #{valid_providers.join(', ')}"
      end
    else
      # Can't find the provider command line tool, maybe try other provider?
      logger.error("The IPMI provider: #{provider} is not installed") if logger
      raise "The IPMI provider: #{provider} is not installed"
    end
  end

  # returns boolean true if privilege type is valid
  def self.supported_privilege_type?(type)
    PRIV_TYPES.include?(type)
  end

  # method used to find the command which also makes it easier to mock with
  def self.locate_command(commandname)
    location = `which #{commandname}`.strip
    location = nil if !$CHILD_STATUS.success?
    location
  end

  # Return true or false if the provider is available
  def self.is_provider_installed?(provider)
    case provider
    when "freeipmi"
      cmdpath = locate_command('ipmipower')
    when "ipmitool"
      cmdpath = locate_command('ipmitool')
    else
      logger.error("Invalid BMC provider type #{provider}") if logger
      false
    end
    # return false if command was not found
    !cmdpath.nil?
  end

  def self.providers
    ["freeipmi", "ipmitool"]
  end

  # returns true if any of the providers are installed
  def self.provider_installed?
    providers_installed.length > 0
  end

  def self.providers_installed
    available = []
    providers.each do |prov|
      available << prov if is_provider_installed?(prov)
    end
    available
  end

  # gets data from the bmc device and puts in a hash for diagnostics
  def self.get_diag(user, pass, host, opts = {:driver => 'lan20', :timeout => 'default'})
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
    File.open('/tmp/rubyipmi_diag_data.txt', 'w') { |f| f.write(data) }
    puts "Created file /tmp/rubyipmi_diag_data.txt"
  end
end
