module Rubyipmi::Freeipmi

  class Lan

    attr_accessor :info
    attr_accessor :channel
    attr_accessor :config

    def initialize(opts)
      @config = Rubyipmi::Freeipmi::BmcConfig.new(opts)

      @info = {}
      @channel = 2
    end


    def info
      if @info.length < 1
        parse(@config.section("Lan_Conf"))
      else
        @info
      end
    end

    def dhcp?
      info.fetch("ip_address_source",nil).match(/dhcp/i) != nil
    end

    def static?
      info.fetch("ip_address_source",nil).match(/static/i) != nil
    end

    def ip
      info.fetch("ip_address", nil)
    end

    def mac
      info.fetch("mac_address", nil)
    end

    def netmask
      info.fetch("subnet_mask", nil)
    end

    def gateway
      info.fetch("default_gateway_ip_address", nil)
    end

  #  def snmp
  #
  #  end

  #  def vlanid
  #
  #  end

  #  def snmp=(community)
  #
  #  end

    # validates that the address, returns true/false
    def validaddr?(source)
      valid = /^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/.match("#{source}")
      if valid.nil?
        raise "#{source} is not a valid address"
      else
        return true
      end
    end

    def ip=(address)
        @config.setsection("Lan_Conf", "IP_Address", address) if validaddr?(address)
    end

    def netmask=(netmask)
        @config.setsection("Lan_Conf", "Subnet_Mask", netmask) if validaddr?(netmask)
    end

    def gateway=(address)
      @config.setsection("Lan_Conf", "Default_Gateway_IP_Address", address) if validaddr?(address)
    end

  #  def vlanid=(vlan)
  #
  #  end

    def parse(landata)
      if ! landata.nil? and ! landata.empty?
        landata.lines.each do |line|
          # clean up the data from spaces
          next if line.match(/#+/)
          next if line.match(/Section/i)
          line.gsub!(/\t/, '')
          item = line.split(/\s+/)
          key = item.first.strip.downcase
          value = item.last.strip
          @info[key] = value

        end
      end
      return @info
    end
  end
end


