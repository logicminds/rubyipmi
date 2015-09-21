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

    def version
      @options['V'] = nil
      runcmd
      @options.delete_notify('V')
      @result.slice(/\d\.\d.\d/)
    end

    # reset the bmc device, useful for troubleshooting
    def reset(type = 'cold')
      if ['cold', 'warm'].include?(type)
        @options["cmdargs"] = "bmc reset #{type}"
        value = runcmd
        @options.delete_notify("cmdargs")
        return value
      else
        logger.error("reset type: #{type} is not a valid choice, use warm or cold") if logger
        raise "reset type: #{type} is not a valid choice, use warm or cold"
      end
    end

    def guid
      @options["cmdargs"] = "bmc guid"
      value = runcmd
      @options.delete_notify("cmdargs")
      if value
        @result.lines.each do |line|
          line.chomp
          line.split(":").last.strip if line =~ /GUID/
        end
      end
    end

    # This function will get the bmcinfo and return a hash of each item in the info
    def retrieve
      @options["cmdargs"] = "bmc info"
      status = runcmd
      @options.delete_notify("cmdargs")
      subkey = nil
      if !status
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
          elsif key == value && subkey
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
