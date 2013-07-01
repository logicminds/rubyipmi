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
    def fanlist(refreshdata=false)
      refresh if refreshdata
      flist = {}
      list.each do | name,sensor |
        if name =~ /.*fan.*/
            flist[name] = sensor
        end
      end
      return flist
    end

    def templist(refreshdata=false)
      refresh if refreshdata
      tlist = {}
      list.each do | name , sensor |
        if name =~ /.*temp|ambient.*/
          tlist[name] = sensor
        end
      end
      return tlist
    end

    def getsensors
      options["cmdargs"] = "sensor"
      value = runcmd
      options.delete_notify("cmdargs")
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
        sensor = Sensor.new(data.first.strip)
        sensor[:value] = data[1].strip
        sensor[:unit] = data[2].strip
        sensor[:status] = data[3].strip
        sensor[:type] = nil
        sensor[:state] = nil
        #sensor[:lower_nonrec] = data[4].strip
        #sensor[:lower_crit] = data[5].strip
        #sensor[:lower_noncrit] = data[6].strip
        #sensor[:upper_noncrit] = data[7].strip
        #sensor[:upper_crit] = data[8].strip
        #sensor[:upper_nonrec] = data[9].strip
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

    #def refresh
    #  data = "sensor get \"#{self[:fullname]}\" "
    #  parse(data)
    #end

    #def parse(data)
    #  values = data.lines.collect do |line|
    #    line.split(':').last.strip
    #  end
    #  # first 4 entries are lines we don't care about
    #  value = values[4].split(/\([\w\W]+\)/)
    #  self[:value] = value.first.strip
    #  self[:unit] = value.last.strip
    #  self[:status] = values[5].strip.chomp
    #  self[:lower_nonrec] = values[6].strip.chomp
    #  self[:lower_crit] = values[7].strip.chomp
    #  self[:lower_noncrit] = values[8].strip.chomp
    #  self[:upper_noncrit] = values[9].strip.chomp
    #  self[:upper_crit] = values[10].strip.chomp
    #  self[:upper_nonrec] = values[11].strip.chomp


    #end

  end

end