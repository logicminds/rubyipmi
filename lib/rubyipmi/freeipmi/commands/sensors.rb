module Rubyipmi::Freeipmi
  class Sensors < Rubyipmi::Freeipmi::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("ipmi-sensors", opts)
    end

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
      list.each do | name,sensor |
        if name =~ /.*fan.*/
          flist[name] = sensor
        end
      end
      return flist
    end

    # returns a hash of sensors where each key is the name of the sensor and the value is the sensor
    def templist(refreshdata = false)
      refresh if refreshdata
      tlist = {}
      list.each do | name , sensor |
        if sensor[:unit] =~ /.*degree.*/ || name =~ /.*temp.*/
          tlist[name] = sensor
        end
      end
      return tlist
    end

    def getsensors
      @options["no-header-output"] = false
      @options["output-sensor-state"] = false
      @options["entity-sensor-names"] = false
      value = runcmd
      @options.delete_notify('no-header-output')
      @options.delete_notify('output-sensor-state')
      @options.delete_notify('entity-sensor-names')
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
      if ! data.nil?
        data.lines.each do | line|
          # skip the header
          sensor = Sensor.new(line)
          sensorlist[sensor[:name]] = sensor
        end
      end
      return sensorlist
    end
  end

  class Sensor < Hash
    def initialize(line)
      parse(line)
      self[:name] = normalize(self[:name])
    end

    private

    def normalize(text)
      text.gsub(/\ /, '_').gsub(/\./, '').downcase
    end

    # Parse the individual sensor
    # Note: not all fields will exist on every server
    def parse(line)
      fields = [:id_num, :name, :value, :unit, :status, :type, :state, :lower_nonrec,
                :lower_crit,:lower_noncrit, :upper_crit, :upper_nonrec, :asserts_enabled, :deasserts_enabled]
      data = line.split(/\|/)
      # should we ever encounter a field not in the fields list, just use a counter based fieldname so we just
      # use field1, field2, field3, ...
      i = 0
      data.each do | value |
        field ||= fields.shift || "field#{i}"
        self[field] = value.strip
        i = i.next
      end
    end
  end
end
