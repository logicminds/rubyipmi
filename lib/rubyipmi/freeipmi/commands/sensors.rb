module Rubyipmi::Freeipmi

  class Sensors < Rubyipmi::Freeipmi::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmi-sensors", opts)
      @options["no-header-output"] = false
      @options["output-sensor-state"] = false
    end

    def refresh
      @sensors = nil
      sensors
    end

    def list
      sensors
    end

    def count
      sensors.count
    end

    def names
      sensors.keys
    end

    def fanlist(refreshdata=false)
      refresh if refreshdata
      flist = []
      values = sensors.each do |sensor|
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
      values = sensors.each do |sensor|
        match = sensor.first.match(/(temp)_(\d+)/)
        next if match.nil?
        if match[1] == "temp"
          num = (match[2].to_i) -1
          tlist[num] = sensor.last[:value]
        end
      end
      tlist
    end



    private

    def sensors
      @sensors ||= parse(getsensors)
    end

    def method_missing(method, *args, &block)
      if not sensors.has_key?(method.to_s)
        raise NoMethodError
      else
        sensors[method.to_s]
      end
    end


    def getsensors
      value = runcmd
      @result
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

