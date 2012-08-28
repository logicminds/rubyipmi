module Rubyipmi::Freeipmi

  class Fru < Rubyipmi::Freeipmi::BaseCommand

    def initialize(opts = ObservableHash.new)
          super("ipmi-fru", opts)
    end

    # return the list of fru information in a hash
    def list
      @list ||= parse(command)
    end

    def serial
      list["chassis_serial_number"]
    end

    def manufacturer
      list["board_manufacturer"]
    end

    def product
      list["board_product_name"]
    end

    private

    def method_missing(method, *args, &block)
          if not list.has_key?(method.to_s)
            raise NoMethodError
          else
            list[method.to_s]
          end
     end

    # parse the fru information
    def parse(data)
      datalist = {}
      data.lines.each do |line|
        key, value = line.split(':')
        next if key =~ /\n/
        value = value.strip
        key = key.gsub(/FRU/, '').strip.gsub(/\ /, '_').downcase
        datalist[key] = value.strip
      end
      return datalist
    end

    # run the command and return result
    def command
       value = runcmd
       if value
         return @result
       end
    end

  end

end