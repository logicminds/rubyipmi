# frozen_string_literal: true

module Rubyipmi::Ipmitool
  class Fru < Rubyipmi::Ipmitool::BaseCommand
    attr_accessor :list

    DEFAULT_FRU = 'builtin_fru_device'

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
      @list = {}
    end

    def names
      list.keys
    end

    def manufacturer
      list[DEFAULT_FRU]['product_manufacturer']
    end

    def serial
      list[DEFAULT_FRU]['board_serial']
    end

    def model
      list[DEFAULT_FRU]['product_manufacturer']
    end

    # return the list of fru information in a hash
    def list
      parse(getfrus) if @list.count < 1
      @list
    end

    # method to retrieve the raw fru data
    def getfrus
      command
    end

    private

    # I use method missing to allow the user to say Fru.<name> which returns a frudata object unless the user
    # passes a keyname from the default fru device
    def method_missing(method, *_args, &_block)
      name = method.to_s
      fru = list.fetch(name, nil)
      # if the user wanted some data from the default fru, lets show the data for the fru.  Otherwise
      # we return the Fru with the given name
      return fru unless fru.nil?
      return list[DEFAULT_FRU][name] if list[DEFAULT_FRU].keys.include?(name)

      # maybe we should return nil instead? hmm...
      raise NoMethodError
    end

    # parse the fru information
    def parse(data)
      return unless data

      parsed_data = []
      data.lines.each do |line|
        # this is the either the first line of of the fru or another fru
        if (line =~ /^FRU.*/) && parsed_data.any?
          # we have reached a new fru device so lets record the previous fru
          new_fru = FruData.new(parsed_data)
          parsed_data = []
          @list[new_fru[:name]] = new_fru
        end

        parsed_data << line
      end
      # process the last fru
      return if parsed_data.none?

      # we have reached a new fru device so lets record the previous fru
      new_fru = FruData.new(parsed_data)
      parsed_data = []
      @list[new_fru[:name]] = new_fru
    end

    # run the command and return result
    def command
      @options["cmdargs"] = "fru"
      value = runcmd
      @options.delete_notify("cmdargs")
      @result if value
    end
  end

  class FruData < Hash
    def name
      self[:name]
    end

    def initialize(data)
      parse(data)
    end

    # parse the fru information that should be an array of lines
    def parse(data)
      return unless data

      data.each do |line|
        key, value = line.split(':', 2)
        if key =~ /^FRU\s+Device.*/
          self[:name] = $~[1].strip.gsub(' ', '_').downcase if value =~ /([\w\s]*)\(.*\)/
        else
          key = key.strip.gsub(' ', '_').downcase
          self[key] = value.strip unless value.nil?
        end
      end
    end

    private

    def method_missing(method, *_args, &_block)
      fetch(method.to_s, nil)
    end
  end
end
