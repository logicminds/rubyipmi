# rubyipmi
This gem is a ruby wrapper for the freeipmi and ipmitool command line tools.
It provides a ruby implementation of ipmi commands that will make it simple to connect to BMC devices from ruby.

[![Build Status](https://travis-ci.org/logicminds/rubyipmi.png)](https://travis-ci.org/logicminds/rubyipmi)

## Using the library in your code

### Install


   1. Install the freeipmi from source (http://www.gnu.org/software/freeipmi/) or ipmitool
   2. gem install rubyipmi

### General Usage

   ``` require 'rubyipmi' ```

#### Create a connection object
   ```conn = Rubyipmi.connect("username", "password", "hostname", "providertype) ```

   Providertype: optional (ipmitool or freeipmi)

   If you don't specify the provider type, Rubyipmi will detect if freeipmi or ipmitool
   is installed and load the first tool found.  If you specify the provider type rubyipmi will only use that specific
   provider.


#### Use power functions (not all listed)
   ```
   conn.chassis.power.on
   conn.chassis.power.off
   conn.chassis.power.on?
   conn.chassis.power.off?
   conn.chassis.power.cycle
   ```

#### Boot to specific device
  ```
   conn.chassis.bootpxe(true, false) # reboot after setting, one time boot only - non persistent
   conn.chassis.bootdisk(false, false) # boot to disk on next reboot, don't reboot automatically

   ```


#### Sensors
    ```
    conn.sensors.names
    conn.sensors.list
    conn.sensors.<sensor name>

    ```

#### Fru
    ```
    conn.fru.list
    conn.fru.serial
    conn.fru.manufacturer
    conn.fru.product

    ```

## Testing
There are a series of automated rspec tests that test the functionality of this library with the ipmi device.
In order to perform use the following steps.

DO NOT PERFORM THESE TEST ON ANY PRODUCTION SYSTEM.  THESE TESTS WILL TURN OFF THE DEVICE!


1.  Install gem via source
2.  bundle install
3.  rake (runs unit tests, does not require a ipmi device) 
3.  rake integration ipmiuser=ipmiuser ipmipass=ipmiuserpass ipmihost=192.168.1.22 ipmiprovider=freeipmi   (fill in your your details)
4.  report any failures with your make/model/firmware revision to corey@logicminds.biz

## Security
 The only security used throughout the library is the use of temporary password files that store the password while
 the command is being executed.  This password file is created and deleted on the fly with every library call.
 The password will not be shown in any logs or process lists due to this enhancement.  The filename is a long random string
 as is the folder name so it would be difficult to guess the password file.  If for some reason a command takes a long
 time to run anyone could get the location of the file but the file is 0600 so it should not be readable by anyone outside
 of the process.


## How the library works
Since this library is based off of running a suite of command line tools I have created a base class called baseCommand
that performs the actual execution of the command.  The baseCommand only executes the command with the supplied
arguments and options and returns the exit status.  Additionally the result of the executed command is stored in
the result variable should we need to retrieve the output of the command. To further extend the baseCommand class.


### Creating a new command
Creating a new command is actually quite simple.  Follow these steps to wrap a freeipmi or ipmitool command.

1.  Create a new subclass of BaseCommand
2.  define the initialize function like so, and pass in the name of the command line tool to the super constructor.

    ```
    def initialize(opts = {})
      @options = opts
      super("bmc-info", opts)
    end

    ```

     ```
        def initialize(opts = {})
          @options = opts
          super("ipmitool", opts)
        end

     ```
3.  Thats it.  The rest of the class is related to running the command and interperting the results

### Writing a function for running a command
The freeipmi command line tools have two different ways to run the commands.

1.  ``` ipmipower --hostname=host --password=pass --username=user --off ```  (single action, multiple arguments)
2.  ``` ipmi-chassis --hostname=host --password=pass --username=user --chassis-identify=FORCE ```  (multiple arguments, one main action with different qualifers)

Because of the varying ways to run a command I have simplified them so it makes it easy to call the command line tools.

1. Each subclassed baseCommand class inherits runcmd, result, cmd, and runcmd_with_args.
2. The cmd executable gets set when instantiating a baseCommand class, where the class also finds the path of the executable.
3. The options variable gets set when instantiating a subclass of the baseCommand class.

### Running the cmd

1.  To run the cmd, just call ``` runcmd ```  (which will automatically set all the options specified in the options hash)
2.  To run the cmd, with arguments and options call ``` runcmd([]) ``` and pass in a array of the arguments.  (Arguments are actions only and look like --off, --on, --action)
3.  To run the cmd, with just arguments ``` runcmd_with_args([]) ```  and pass in a array of the arguments.  (Example: 192.168.1.1)

### The Options hash
The options hash can be considered a global hash that is passed in through the connection object.
Most of the options will be set at the connection level.  However, most commands require additional options
that should be set at the subclassed BaseCommand level.  You must not forget to unset the option after calling
the runcmd command.  Failure to do so will add previous options to subsequent run options.

Example:

```
def ledlight(status=false, delay=300)
      if status
        if delay <= 0
          options["chassis-identify"] = "FORCE"
        else
          options["chassis-identify"] = delay
        end
      else
        options["chassis-identify"] = "TURN-OFF"
      end
      # Run the command
      run
      # unset the option by deleting from hash
      options.delete("chassis-identify")
end

```

### How to get the results of the command
After running a command it may be desirable to get the results for further processing.
Note that there are two kinds of results.
1. the text returned from the shell command, this is stored in @results
2. the status value returned from the shell command (true or false only) this is returned from runcmd.

To get the results:

Example:

```
    def status
      value = command("--stat")
      if value == true
         @result.split(":").last.chomp.trim
      end
    end

    def command(opt)
      status = run([opt])
      return status
    end

    def on?
      status == "on"
    end

```

### The command function
Although its not necessary to implement the command function it may be desirable if your code starts to repeat itself.
  In this example the command function is just a wrapper command that calls run.  Your implementation will vary,
  but be sure to always call it the "command" function, so its easily identified.
  Additionally, should this gem ever become out of date one could call the command function and pass in any
  arguments that have not already been implemented in the rest of the class.

```
 def command(opt)
      status = runcmd([opt])
      return status
 end

 def on
      command("--on")
 end

```

## The following are tools bundled with freeipmi

* ipmi-chassis
* ipmi-oem
* ipmi-chassis-config
* ipmiping
* ipmiconsole
* ipmipower
* ipmidetect
* ipmi-raw
* ipmi-fru
* ipmi-sel
* ipmi-locate
* ipmi-sensors
* ipmimonitoring
* ipmi-sensors-config
* bmc-config
* bmc-device
* bmc-info

## To contrast ipmitool has one command with many options
* ipmitool



## Auto Detect workarounds
IPMI is great for a vendor neutral management interface.  However, not all servers are 100% compatible with the specifications.
In order to overcome ipmi non-compliance there will be some workarounds built into this library



## Contributing to rubyipmi

* Check out the latest code to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Corey Osman. See LICENSE.txt for
further details.


## Freeipmi Documented Workarounds


One of my design goals is to raise exceptions and have the library try workarounds before ultimately failing since there is a whole list of workarounds that can be attempted.However, it would be nice to know the make and model of the server up front to decrease workaround attempts.

So essentially I need to figure out how to save a command call and then retry if it doesn't work.

With so many different vendors implementing their own IPMI solutions, different vendors may implement their IPMI protocols incorrectly. The following describes a number of workarounds currently available to handle discovered compliance issues. When possible, workarounds have been implemented so they will be transparent to the user. However, some will require the user to specify a workaround be used via the -W option.
The hardware listed below may only indicate the hardware that a problem was discovered on. Newer versions of hardware may fix the problems indicated below. Similar machines from vendors may or may not exhibit the same problems. Different vendors may license their firmware from the same IPMI firmware developer, so it may be worthwhile to try workarounds listed below even if your motherboard is not listed.

If you believe your hardware has an additional compliance issue that needs a workaround to be implemented, please contact the FreeIPMI maintainers on <freeipmi-users@gnu.org> or <freeipmi-devel@gnu.org>.

assumeio - This workaround flag will assume inband interfaces communicate with system I/O rather than being memory-mapped. This will work around systems that report invalid base addresses. Those hitting this issue may see "device not supported" or "could not find inband device" errors. Issue observed on HP ProLiant DL145 G1.

spinpoll - This workaround flag will inform some inband drivers (most notably the KCS driver) to spin while polling rather than putting the process to sleep. This may significantly improve the wall clock running time of tools because an operating system scheduler's granularity may be much larger than the time it takes to perform a single IPMI message transaction. However, by spinning, your system may be performing less useful work by not contexting out the tool for a more useful task.

authcap - This workaround flag will skip early checks for username capabilities, authentication capabilities, and K_g support and allow IPMI authentication to succeed. It works around multiple issues in which the remote system does not properly report username capabilities, authentication capabilities, or K_g status. Those hitting this issue may see "username invalid", "authentication type unavailable for attempted privilege level", or "k_g invalid" errors. Issue observed on Asus P5M2/P5MT-R/RS162-E4/RX4, Intel SR1520ML/X38ML, and Sun Fire 2200/4150/4450 with ELOM.

idzero - This workaround flag will allow empty session IDs to be accepted by the client. It works around IPMI sessions that report empty session IDs to the client. Those hitting this issue may see "session timeout" errors. Issue observed on Tyan S2882 with M3289 BMC.

unexpectedauth - This workaround flag will allow unexpected non-null authcodes to be checked as though they were expected. It works around an issue when packets contain non-null authentication data when they should be null due to disabled per-message authentication. Those hitting this issue may see "session timeout" errors. Issue observed on Dell PowerEdge 2850,SC1425. Confirmed fixed on newer firmware.

forcepermsg - This workaround flag will force per-message authentication to be used no matter what is advertised by the remote system. It works around an issue when per-message authentication is advertised as disabled on the remote system, but it is actually required for the protocol. Those hitting this issue may see "session timeout" errors. Issue observed on IBM eServer 325.

endianseq - This workaround flag will flip the endian of the session sequence numbers to allow the session to continue properly. It works around IPMI 1.5 session sequence numbers that are the wrong endian. Those hitting this issue may see "session timeout" errors. Issue observed on some Sun ILOM 1.0/2.0 (depends on service processor endian).

intel20 - This workaround flag will work around several Intel IPMI 2.0 authentication issues. The issues covered include padding of usernames, and password truncation if the authentication algorithm is HMAC-MD5-128. Those hitting this issue may see "username invalid", "password invalid", or "k_g invalid" errors. Issue observed on Intel SE7520AF2 with Intel Server Management Module (Professional Edition).

supermicro20 - This workaround flag will work around several Supermicro IPMI 2.0 authentication issues on motherboards w/ Peppercon IPMI firmware. The issues covered include handling invalid length authentication codes. Those hitting this issue may see "password invalid" errors. Issue observed on Supermicro H8QME with SIMSO daughter card. Confirmed fixed on newerver firmware.

sun20 - This workaround flag will work work around several Sun IPMI 2.0 authentication issues. The issues covered include invalid lengthed hash keys, improperly hashed keys, and invalid cipher suite records. Those hitting this issue may see "password invalid" or "bmc error" errors. Issue observed on Sun Fire 4100/4200/4500 with ILOM. This workaround automatically includes the "opensesspriv" workaround.

opensesspriv - This workaround flag will slightly alter FreeIPMI's IPMI 2.0 connection protocol to workaround an invalid hashing algorithm used by the remote system. The privilege level sent during the Open Session stage of an IPMI 2.0 connection is used for hashing keys instead of the privilege level sent during the RAKP1 connection stage. Those hitting this issue may see "password invalid", "k_g invalid", or "bad rmcpplus status code" errors. Issue observed on Sun Fire 4100/4200/4500 with ILOM, Inventec 5441/Dell Xanadu II, Supermicro X8DTH, Supermicro X8DTG, Intel S5500WBV/Penguin Relion 700, Intel S2600JF/Appro 512X, and Quanta QSSC-S4R//Appro GB812X-CN. This workaround is automatically triggered with the "sun20" workaround.

integritycheckvalue - This workaround flag will work around an invalid integrity check value during an IPMI 2.0 session establishment when using Cipher Suite ID 0. The integrity check value should be 0 length, however the remote motherboard responds with a non-empty field. Those hitting this issue may see "k_g invalid" errors. Issue observed on Supermicro X8DTG, Supermicro X8DTU, and Intel S5500WBV/Penguin Relion 700, and Intel S2600JF/Appro 512X.

No IPMI 1.5 Support - Some motherboards that support IPMI 2.0 have been found to not support IPMI 1.5. Those hitting this issue may see "ipmi 2.0 unavailable" or "connection timeout" errors. This issue can be worked around by using IPMI 2.0 instead of IPMI 1.5 by specifying --driver-address=LAN_2_0. Issue observed on HP Proliant DL 145.

slowcommit - This workaround will slow down commits to the BMC by sleeping one second between the commit of sections. It works around motherboards that have BMCs that can be overwhelmed by commits. Those hitting this issue may see commit errors or commits not being written to the BMC. Issue observed on Supermicro H8QME.

veryslowcommit - This workaround will slow down commits to the BMC by sleeping one second between the commit of every key. It works around motherboards that have BMCs that can be overwhelmed by commits. Those hitting this issue may see commit errors or commits not being written to the BMC. Issue observed on Quanta S99Q/Dell FS12-TY.



