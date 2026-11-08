# frozen_string_literal: true

module Rubyipmi::Freeipmi
  class BmcInfo < Rubyipmi::Freeipmi::BaseCommand
    def initialize(opts = ObservableHash.new)
      super("bmc-info", opts)
    end

    def guid
      options["get-device-guid"] = false
      status = runcmd
      options.delete_notify("get-device-guid")
      raise @result unless status

      @result.chomp.strip
    end

    def retrieve
      bmcinfo = {}
      status = runcmd
      subkey = nil
      raise @result unless status

      @result.lines.each do |line|
        # clean up the data from spaces
        item = line.split(':')
        key = item.first.strip
        value = item.last.strip
        # if the following condition is met we have subvalues
        if key == value && !subkey
          subkey = key
          bmcinfo[subkey] = []
        elsif key == value && subkey
          # subvalue found
          bmcinfo[subkey] << value.gsub(/\[|\]/, "")
        else
          # Normal key/value pair with no subkeys
          subkey = nil
          bmcinfo[key] = value
        end
      end
      bmcinfo
    end
  end
end
