module Rubyipmi::Ipmitool
  class Sensors < Rubyipmi::Ipmitool::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
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

    def getsensors
      options["cmdargs"] = "sensor"
      runcmd
      options.delete_notify("cmdargs")
      @result
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
      fields = [:name, :value, :unit, :status, :type, :state, :lower_nonrec,
                :lower_crit, :lower_noncrit, :upper_crit, :upper_nonrec, :asserts_enabled, :deasserts_enabled]
      # skip the header
      data = line.split(/\|/)
      # should we ever encounter a field not in the fields list, just use a counter based fieldname
      i = 0
      data.each do |value|
        field ||= fields.shift || "field#{i}"
        self[field] = value.strip
        i = i.next
      end
    end
  end
end
