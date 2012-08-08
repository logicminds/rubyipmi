module Rubyipmi::Ipmitool

  class Bmc < Rubyipmi::Ipmitool::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
    end

    def guid
      @options["cmdargs"] = "bmc gui"
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

    def info
      @info ||= Rubyipmi::Ipmitool::BmcInfo.new(@options)
    end
  end
end
