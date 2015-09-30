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
      flist = {}
      list.each do |name, sensor|
        flist[name] = sensor if name =~ /.*fan.*/
      end
      flist
    end

    # returns a hash of sensors where each key is the name of the sensor and the value is the sensor
    def templist(refreshdata = false)
      refresh if refreshdata
      tlist = {}
      list.each do |name, sensor|
        if sensor[:unit] =~ /.*degree.*/ || name =~ /.*temp.*/
          tlist[name] = sensor
        end
      end
      tlist
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
      sensorlist = {}
      unless data.nil?
        data.lines.each do |line|
          # skip the header
          sensor = Sensor.new(line)
          sensorlist[sensor[:name]] = sensor
        end
      end
      sensorlist
    end
  end
end
