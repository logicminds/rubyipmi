module Rubyipmi
  module SensorsMixin
    def refresh
      @sensors = nil
      list
    end

    def list
      @sensors ||= parse(getsensors)
    end

    def count
      list.count
    end

    def names
      list.keys
    end

    # returns a hash of fan sensors where the key is fan name and value is the sensor
    def fanlist(refreshdata = false)
      refresh if refreshdata
      list.each_with_object({}) { |(name, sensor), flist| flist[name] = sensor if name =~ /.*fan.*/ }
    end

    # returns a hash of sensors where each key is the name of the sensor and the value is the sensor
    def templist(refreshdata = false)
      refresh if refreshdata
      list.each_with_object({}) do |(name, sensor), tlist|
        tlist[name] = sensor if (sensor[:unit] =~ /.*degree.*/ || name =~ /.*temp.*/)
      end
    end

    private

    def method_missing(method, *_args, &_block)
      if !list.key?(method.to_s)
        raise NoMethodError
      else
        list[method.to_s]
      end
    end

    def parse(data)
      return {} if data.nil?

      data.lines.each_with_object({}) do |line, sensorlist|
        # skip the header
        sensor = sensor_class.new(line)
        sensorlist[sensor[:name]] = sensor
      end
    end
  end
end
