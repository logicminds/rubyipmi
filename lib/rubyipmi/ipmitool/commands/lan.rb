module Rubyipmi::Ipmitool
  class Lan < Rubyipmi::Ipmitool::BaseCommand

    attr_accessor :info
    attr_accessor :channel
    MAX_RETRY = 1

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
      @info = {}
      @channel = 2
    end

    # sets the info var to be empty causing the variable to repopulate upon the next call to info
    def refresh
      @info = {}
    end

    def channel=(num)
      refresh
      @channel = num
    end

    def info
      retrycount = 0
      if @info.length < 1
        begin
          parse(print)
        rescue
          # sometimes we need to get the info from channel 1,
          # wait for error to occur then retry using channel 1
          if retrycount < MAX_RETRY
            @channel = 1
            retry
          end
        end
      else
        # return the cached info
        @info
      end
    end

    def snmp
      info.fetch("snmp_community_string",nil)
    end

    def ip
      info.fetch("ip_address",nil)
    end

    def mac
      info.fetch("mac_address",nil)
    end

    def netmask
      info.fetch("subnet_mask",nil)
    end

    def gateway
      info.fetch("default_gateway_ip",nil)
    end

    def vlanid
      info.fetch("802.1q_vlan_id",nil)
    end

  #  def snmp=(community)
  #    @options["cmdargs"] = "lan set #{channel} snmp #{community}"
  #    value = runcmd
  #    @options.delete_notify("cmdargs")
  #    return value
  #  end

    def ip=(address)
      @options["cmdargs"] = "lan set #{channel} ipaddr #{address}"
      value = runcmd
      @options.delete_notify("cmdargs")
      return value
    end

    def netmask=(mask)
      @options["cmdargs"] = "lan set #{channel} netmask #{mask}"
      value = runcmd
      @options.delete_notify("cmdargs")
      return value
    end

    def gateway=(address)
      @options["cmdargs"] = "lan set #{channel} defgw ipaddr #{address}"
      value = runcmd
      @options.delete_notify("cmdargs")
      return value
    end

    def dhcp?
      info.fetch("ip_address_source",nil).match(/dhcp/i) != nil
    end

    def static?
      info.fetch("ip_address_source",nil).match(/static/i) != nil
    end

    def vlanid=(vlan)
      @options["cmdargs"] = "lan set #{channel} vlan id #{vlan}"
      value = runcmd
      @options.delete_notify("cmdargs")
      return value
    end

    private

    def print
      @options["cmdargs"] = "lan print"
      value = runcmd
      @options.delete_notify("cmdargs")
      if value
        @result
      end
    end

    def parse(landata)
      landata.lines.each do |line|
        # clean up the data from spaces
        item = line.split(':', 2)
        key = normalize(item.first.strip)
        value = item.last.strip
        @info[key] = value
      end
      return @info
    end

    def normalize(text)
      text.gsub(/\ /, '_').gsub(/\./, '').downcase
    end
  end
end
