require 'rubyipmi/commands/mixins/sensors_mixin'

module Rubyipmi::Freeipmi
  class Sensors < Rubyipmi::Freeipmi::BaseCommand
    include Rubyipmi::SensorsMixin

    def initialize(opts = ObservableHash.new)
      super("ipmi-sensors", opts)
    end

    def getsensors
      @options["no-header-output"] = false
      @options["output-sensor-state"] = false
      @options["entity-sensor-names"] = false
      runcmd
      @options.delete_notify('no-header-output')
      @options.delete_notify('output-sensor-state')
      @options.delete_notify('entity-sensor-names')
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
      fields = [:id_num, :name, :value, :unit, :status, :type, :state, :lower_nonrec,
                :lower_crit, :lower_noncrit, :upper_crit, :upper_nonrec, :asserts_enabled, :deasserts_enabled]
      data = line.split(/\|/)
      # should we ever encounter a field not in the fields list, just use a counter based fieldname so we just
      # use field1, field2, field3, ...
      i = 0
      data.each do |value|
        field ||= fields.shift || "field#{i}"
        self[field] = value.strip
        i = i.next
      end
    end
  end
end
