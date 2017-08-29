require 'rubyipmi/commands/mixins/sensors_mixin'

module Rubyipmi::Ipmitool
  class Sensors < Rubyipmi::Ipmitool::BaseCommand
    include Rubyipmi::SensorsMixin

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
    end

    def getsensors
      options["cmdargs"] = "sensor"
      runcmd
      options.delete_notify("cmdargs")
      @result
    end

    def sensor_class
      Sensor
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
