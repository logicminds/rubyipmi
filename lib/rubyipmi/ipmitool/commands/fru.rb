module Rubyipmi::Ipmitool

  class Fru < Rubyipmi::Ipmitool::BaseCommand

    attr_accessor :list

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
      @list = {}
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
        if list.has_key?('builtin_fru_device')
          if list['builtin_fru_device'].has_key?(method.to_s)
            list['builtin_fru_device'][method.to_s]
          end
        else
          raise NoMethodError
        end
     end

    # parse the fru information
    def parse(data)
      if ! data.nil?
        parsed_data = []
        data.lines.each do |line|
          if line =~ /^FRU\ Device\ Description.*/
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
  end


    # run the command and return result
    def command
       @options["cmdargs"] = "fru"
       value = runcmd
       @options.delete_notify("cmdargs")
       if value
         return @result
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
          if key =~ /^FRU\ Device\ Description.*/
            if value =~ /([\w\s]*)\(.*\)/
             self[:name] = $~[1].strip.gsub(/\ /, '_').downcase
            end
          else
            key = key.strip.gsub(/\ /, '_').downcase
            if ! value.nil?
              self[key] = value.strip
            end
          end
        end
      end
    end

  end


end