module Rubyipmi::Freeipmi

  class Sensors < Rubyipmi::Freeipmi::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmi-sensors", opts)
      @options["no-header-output"] = false
      @options["output-sensor-state"] = false
    end

    def refresh
      @sensors = nil
      list
    end

    def count
      list.count
    end

    def names
      list.keys
    end

    def fanlist(refreshdata=false)
      return list
      refresh if refreshdata
      flist = []
      values = list.names.each do |sensor|
        match = sensor.first.match(/(fan)_(\d+)/)
        next if match.nil?
        if match[1] == "fan"
          num = (match[2].to_i) -1
          flist[num] = sensor.last[:value]
        end
      end
      flist
    end

    def templist(refreshdata=false)
      refresh if refreshdata
      tlist = []
      values = list.each do |sensor|
        match = sensor.first.match(/(temp)_(\d+)/)
        next if match.nil?
        if match[1] == "temp"
          num = (match[2].to_i) -1
          tlist[num] = sensor.last[:value]
        end
      end
      tlist
    end

    def list
      @sensors ||= parse(getsensors)
    end

    def getsensors
      value = runcmd
      @result
    end

    private



    def method_missing(method, *args, &block)
      if not list.has_key?(method.to_s)
        raise NoMethodError
      else
        list[method.to_s]
      end
    end




    def parse(data)
      sensorlist = {}
      data.lines.each do | line|
        # skip the header
        data = line.split(/\|/)
        # remove number column
        data.shift
        sensor = Sensor.new(data[0].strip)
        sensor[:type] = data[1].strip
        sensor[:state] = data[2].strip
        sensor[:value] = data[3].strip
        sensor[:unit] = data[4].strip
        sensor[:status] = data[5].strip
        sensorlist[sensor[:name]] = sensor

      end
      return sensorlist

    end
  end

  class Sensor < Hash

    def initialize(sname)
      self[:fullname] = sname
      self[:name] = sname.gsub(/\ /, '_').gsub(/\./, '').downcase
    end

  end
end

