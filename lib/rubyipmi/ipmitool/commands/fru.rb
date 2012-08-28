module Rubyipmi::Ipmitool

  class Fru < Rubyipmi::Ipmitool::BaseCommand

    def initialize(opts = ObservableHash.new)
      super("ipmitool", opts)
    end

    # return the list of fru information in a hash
    def list
      @list ||= parse(command)
    end

    # returns the serial of the board
    def serial
       list["board_serial"]
    end

    # returns the manufacturer of the server
    def manufacturer
       list["product_manufacturer"]
    end

    # returns the product name of the server
    def product
       list["product_name"]
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
        key = key.strip.gsub(/\ /, '_').downcase
        datalist[key] = value.strip
      end
      return datalist
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

  end

end