module Rubyipmi::Freeipmi

  class Lan

    attr_accessor :info
    attr_accessor :channel


    def initialize(opts = {})
      @config ||= Rubyipmi::Freeipmi::BmcConfig.new(opts)
      @info = {}
      @channel = 2
    end

    def info
      if @info.length < 1
        parse(@config.section("Lan_Conf"))
      end
    end

    def dhcp?
      if @info.length < 1
        parse(@config.section("Lan_Conf"))
      end
      @info["ip address source"].match(/dhcp/i) != nil
    end

    def static?
      if @info.length < 1
        parse(@config.section("Lan_Conf"))
      end
      @info["ip_address_source"].match(/static/i) != nil
    end

    def ip
      if @info.length < 1
        parse(@config.section("Lan_Conf"))
      end
      @info["ip_address"]
    end

    def mac
      if @info.length < 1
        parse(@config.section("Lan_Conf"))
      end
      @info["mac_address"]
    end

    def subnet
      if @info.length < 1
        parse(@config.section("Lan_Conf"))
      end
      @info["subnet_mask"]
    end

    def gateway
      if @info.length < 1
        parse(@config.section("Lan_Conf"))
      end
      @info["default_gateway_ip_address"]
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

    def set_ip(address, static=true)
      @config.setsection("Lan_Conf", "IP_Address", address)
    end

    def set_subnet(subnet)
      @config.setsection("Lan_Conf", "Subnet_Mask", subnet)
    end

    def set_gateway(address)
      @config.setsection("Lan_Conf", "Default_Gateway_IP_Address", address)
    end

  #  def vlanid=(vlan)
  #
  #  end

    def parse(landata)
      landata.lines.each do |line|
        # clean up the data from spaces
        next if line.start_with?("#")
        item = line.split(/\t/)
        next if item.length > 2
        key = item.first.strip.downcase
        value = item.last.strip
        @info[key] = value

      end
      return @info
    end
  end
end


