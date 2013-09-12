module Rubyipmi::Ipmitool

  class Bmc < Rubyipmi::Ipmitool::BaseCommand

    attr_accessor :config

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
      @bmcinfo = {}
    end

    def lan
      @lan ||= Rubyipmi::Ipmitool::Lan.new(@options)
    end

    def info
      if @bmcinfo.length > 0
        @bmcinfo
      else
        retrieve
      end
    end

    # reset the bmc device, useful for troubleshooting
    def reset(type='cold')
      if ['cold', 'warm'].include?(type)
         @options["cmdargs"] = "bmc reset #{type}"
         value = runcmd()
         @options.delete_notify("cmdargs")
         return value
      else
        raise "reset type: #{type} is not a valid choice, use warm or cold"
      end

    end

    def guid
      @options["cmdargs"] = "bmc guid"
      value = runcmd()
      @options.delete_notify("cmdargs")
      if value
        @result.lines.each { | line |
          line.chomp
          if line =~ /GUID/
            line.split(":").last.strip
          end
        }
      end

    end

    # This function will get the bmcinfo and return a hash of each item in the info
    def retrieve
      @options["cmdargs"] = "bmc info"
      status = runcmd
      @options.delete_notify("cmdargs")
      subkey = nil
      if not status
        raise @result
      else
        @result.lines.each do |line|
          # clean up the data from spaces
          item = line.split(':')
          key = item.first.strip
          value = item.last.strip
          # if the following condition is met we have subvalues
          if value.empty?
            subkey = key
            @bmcinfo[subkey] = []
          elsif key == value and subkey
            # subvalue found
            @bmcinfo[subkey] << value
          else
            # Normal key/value pair with no subkeys
            subkey = nil
            @bmcinfo[key] = value
          end
        end
        return @bmcinfo
      end
    end


  end
end
