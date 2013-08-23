require 'rubyipmi/ipmitool/errorcodes'

module Rubyipmi::Ipmitool

  class BaseCommand < Rubyipmi::BaseCommand

    MAX_RETRY_COUNT = ErrorCodes.length


    def setpass
      super
      @options["f"] = @passfile.path
      @passfile.write "#{@options["P"]}"
      @passfile.rewind
      @passfile.close
    end

    def makecommand
      args = ''
      # need to format the options to ipmitool format
      @options.each do  |k,v|
        # must remove from command line as its handled via conf file
        next if k == "P"
        next if k == "cmdargs"
        args << " -#{k} #{v}"
      end

      # since ipmitool requires commands to be in specific order

      args << ' ' + options.fetch('cmdargs', '')

      return "#{cmd} #{args.lstrip}"
    end

  end


end