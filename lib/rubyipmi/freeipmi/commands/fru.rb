module Rubyipmi::Freeipmi
  class Fru < Rubyipmi::Freeipmi::BaseCommand
    attr_accessor :list

    DEFAULT_FRU = 'default_fru_device'

    def initialize(opts = ObservableHash.new)
      super("ipmi-fru", opts)
      @list = {}
    end

    def get_from_list(key)
      return unless list.key?(DEFAULT_FRU)
      list[DEFAULT_FRU][key] if list[DEFAULT_FRU].key?(key)
    end

    def manufacturer
      get_from_list('board_manufacturer')
    end

    def board_serial
      get_from_list('board_serial_number')
    end

    def serial
      get_from_list('board_serial_number')
    end

    def model
      get_from_list('board_product_name')
    end

    # method to retrieve the raw fru data
    def getfrus
      command
      @result
    end

    def names
      list.keys
    end

    # return the list of fru information in a hash
    def list
      parse(getfrus) if @list.count < 1
      @list
    end

    private

    def method_missing(method, *_args, &_block)
      name = method.to_s
      fru = list.fetch(name, nil)
      # if the user wanted some data from the default fru, lets show the data for the fru.  Otherwise
      # we return the Fru with the given name
      if fru.nil?
        if list[DEFAULT_FRU].keys.include?(name)
          return list[DEFAULT_FRU][name]
        else
          # maybe we should return nil instead? hmm...
          raise NoMethodError
        end
      else
        return fru
      end
    end

    # parse the fru information
    def parse(data)
      if !data.nil? && !data.empty?
        parsed_data = []
        data.lines.each do |line|
          if line =~ /^FRU.*/
            # this is the either the first line of of the fru or another fru
            if parsed_data.count != 0
              # we have reached a new fru device so lets record the previous fru
              new_fru = FruData.new(parsed_data)
              parsed_data = []
              @list[new_fru[:name]] = new_fru
            end
          end
          parsed_data << line
        end
        # process the last fru
        if parsed_data.count != 0
          # we have reached a new fru device so lets record the previous fru
          new_fru = FruData.new(parsed_data)
          parsed_data = []
          @list[new_fru[:name]] = new_fru
        end
      end
      @list
    end

    # run the command and return result
    def command
      value = runcmd
      return @result if value
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
        if key =~ /^FRU.*/
          if value =~ /([\w\s]*)\(.*\)/
            self[:name] = $~[1].strip.gsub(/\ /, '_').downcase
          end
        else
          key = key.strip.gsub(/\ /, '_').downcase.gsub(/fru_/, '')
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
