module Rubyipmi::Freeipmi

  class Fru < Rubyipmi::Freeipmi::BaseCommand

    attr_accessor :list

    DEFAULT_FRU = 'default_fru_device'

    def initialize(opts = ObservableHash.new)
        super("ipmi-fru", opts)
        @list = {}
    end

    # method to retrieve the raw fru data
    def getfrus
      command
    end

    def names
      list.keys
    end

    # return the list of fru information in a hash
    def list
      if @list.count < 1
        parse(getfrus)
      end
      @list
    end

    # method to retrieve the raw fru data
    def getfrus
      command
    end

    private

    def method_missing(method, *args, &block)
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
      if ! data.nil?
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
    end

    # run the command and return result
    def command
       value = runcmd
       if value
         return @result
       end
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
      if ! data.nil?
        data.each do |line|
          key, value = line.split(':', 2)
          if key =~ /^FRU.*/
            if value =~ /([\w\s]*)\(.*\)/
              self[:name] = $~[1].strip.gsub(/\ /, '_').downcase
            end
          else
            key = key.strip.gsub(/\ /, '_').downcase.gsub(/fru_/, '')
            if ! value.nil?
              self[key] = value.strip

            end
          end
        end
      end
    end

    private

    def method_missing(method, *args, &block)
      self.fetch(method.to_s, nil)
    end

  end
end