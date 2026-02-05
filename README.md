# Rubyipmi

A Ruby library for controlling and querying BMC (Baseboard Management Controller) devices. Rubyipmi wraps the **freeipmi** and **ipmitool** command-line tools behind a consistent, object-oriented API so you can drive IPMI from Ruby scripts, monitoring tools, or automation without shelling out or parsing CLI output yourself.

---

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Scenarios](#usage-scenarios)
  - [Connection options](#connection-options)
  - [Power control](#power-control)
  - [Boot device and PXE](#boot-device-and-pxe)
  - [Sensors and monitoring](#sensors-and-monitoring)
  - [FRU (Field Replaceable Unit) info](#fru-field-replaceable-unit-info)
  - [BMC info and diagnostics](#bmc-info-and-diagnostics)
- [Development](#development)
  - [Running tests](#running-tests)
  - [Extending the library](#extending-the-library)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Projects using Rubyipmi](#projects-using-rubyipmi)
- [Support](#support)
- [Contributing](#contributing)
- [License](#license)
- [FreeIPMI workarounds](#freeipmi-documented-workarounds)

---

## Requirements

- **Ruby** 3.0+
- One of:
  - [freeipmi](https://www.gnu.org/software/freeipmi/) (from source or package), or
  - **ipmitool**

Rubyipmi auto-detects which provider is installed. You can also force a specific provider (see [Connection options](#connection-options)).

---

## Installation

Add to your Gemfile:

```ruby
gem 'rubyipmi'
```

Then:

```bash
bundle install
```

Or install globally:

```bash
gem install rubyipmi
```

---

## Quick Start

```ruby
require 'rubyipmi'

# Connect (provider is auto-detected: freeipmi or ipmitool)
conn = Rubyipmi.connect("username", "password", "hostname")

# Verify connectivity
conn.connection_works?   # => true/false

# Power
conn.chassis.power.on?
conn.chassis.power.off
conn.chassis.power.on
conn.chassis.power.cycle

# Sensors
conn.sensors.names
conn.sensors.list

# FRU (serial, model, etc.)
conn.fru.list
conn.fru.serial
conn.fru.manufacturer
conn.fru.product

# BMC info
conn.bmc.info
conn.bmc.version
```

---

## Usage Scenarios

### Connection options

**Basic connection** (auto-detect provider):

```ruby
conn = Rubyipmi.connect("username", "password", "192.168.1.10")
```

**Choose provider explicitly** (`'auto'`, `'freeipmi'`, or `'ipmitool'`):

```ruby
conn = Rubyipmi.connect("username", "password", "192.168.1.10", "freeipmi")
```

**Extra options** (privilege, driver):

```ruby
conn = Rubyipmi.connect("username", "password", "192.168.1.10", "freeipmi", {
  privilege: 'ADMINISTRATOR',
  driver:    'lan20'   # or 'lan15', 'auto', 'open'
})
```

**Local host with OpenIPMI** (no credentials; run on the same host as the BMC):

```ruby
# Uses openipmi driver; no username/password/host needed
conn = Rubyipmi.connect(nil, nil, "localhost", "freeipmi", { driver: 'open' })
```

Valid `privilege` values: `'CALLBACK'`, `'USER'`, `'OPERATOR'`, `'ADMINISTRATOR'`.  
Valid `driver` values: `'auto'`, `'lan15'`, `'lan20'`, `'open'`.

---

### Power control

```ruby
conn = Rubyipmi.connect(user, pass, host)

conn.chassis.power.on          # power on
conn.chassis.power.off         # power off
conn.chassis.power.cycle       # power cycle
conn.chassis.power.on?         # => true if on
conn.chassis.power.off?        # => true if off
```

---

### Boot device and PXE

Set next boot device and optionally reboot. Methods take `(reboot, persistent)`:

```ruby
conn = Rubyipmi.connect(user, pass, host)

# PXE once, then revert to normal boot (reboot now)
conn.chassis.bootpxe(true, false)

# PXE on next reboot only (no reboot now)
conn.chassis.bootpxe(false, false)

# Boot from disk once, with immediate reboot
conn.chassis.bootdisk(true, false)

# Boot from disk from now on (persistent)
conn.chassis.bootdisk(true, true)

# CDROM
conn.chassis.bootcdrom(true, false)
```

`reboot`: perform a power cycle after setting the boot device.  
`persistent`: keep the boot device across reboots (otherwise one-time).

---

### Sensors and monitoring

Useful for monitoring stacks (e.g. Sensu, Prometheus exporters):

```ruby
conn = Rubyipmi.connect(user, pass, host)

# List sensor names
conn.sensors.names

# Full sensor list (array of sensor data)
conn.sensors.list

# Access a sensor by normalized name (underscores, no spaces/dots)
conn.sensors.temperature_cpu1
conn.sensors.fan_speed_1
```

Example: collect temperatures for a custom monitor:

```ruby
conn.sensors.list.each do |sensor|
  next unless sensor[:name].to_s.include?('temp')
  puts "#{sensor[:name]}: #{sensor[:value]} #{sensor[:unit]}"
end
```

---

### FRU (Field Replaceable Unit) info

Serial numbers, product names, manufacturers:

```ruby
conn = Rubyipmi.connect(user, pass, host)

conn.fru.list           # full FRU data
conn.fru.serial         # serial number(s)
conn.fru.manufacturer   # manufacturer
conn.fru.product        # product name
```

Handy for asset tracking or automation that needs to identify hardware.

---

### BMC info and diagnostics

**BMC info and version:**

```ruby
conn.bmc.info
conn.bmc.version
```

**Connection check** (single place to validate credentials/host):

```ruby
if conn.connection_works?
  # proceed with power, sensors, etc.
else
  # handle unreachable or bad credentials
end
```

**Generate a diagnostics file** (for bug reports or vendor-specific issues):

```ruby
require 'rubyipmi'
Rubyipmi.get_diag(user, pass, host)
# Writes: /tmp/rubyipmi_diag_data.txt
# Review for sensitive data (IP/MAC, etc.) before sharing.
```

With debug logging:

```ruby
require 'rubyipmi'
require 'logger'
Rubyipmi.log_level = Logger::DEBUG
Rubyipmi.get_diag(user, pass, host)
# Also creates /tmp/rubyipmi.log with commands run
```

---

## Development

### Running tests

**Unit tests** (no BMC required; mocks only):

```bash
bundle install
bundle exec rake unit
```

**Integration tests** (require a real BMC; **they will power off/cycle the device**):

Do **not** run on production systems.

```bash
bundle exec rake integration \
  ipmiuser=USER \
  ipmipass=PASS \
  ipmihost=192.168.1.10 \
  ipmiprovider=freeipmi
```

**Vagrant-based integration** (if you use the spec Vagrant setup):

```bash
cd spec && vagrant up && vagrant provision
vagrant ssh -c "/rubyipmi/rake integration ipmiuser=... ipmipass=... ipmihost=... ipmiprovider=freeipmi"
```

**CI:** The repo uses GitHub Actions; see `.github/workflows/test.yml`. Typical flow: checkout → Ruby 3.x → `bundle install` → `bundle exec rake unit` → `gem build`.

---

### Extending the library

Rubyipmi runs the underlying CLI tools via a small command layer. To add or wrap new behavior:

1. **Subclass the provider’s BaseCommand**  
   Use `Rubyipmi::Freeipmi::Commands::BaseCommand` or `Rubyipmi::Ipmitool::Commands::BaseCommand`.

2. **Initialize with the executable name** (e.g. freeipmi’s `bmc-info` or `ipmitool`):

   ```ruby
   def initialize(opts = {})
     @options = opts
     super("bmc-info", opts)   # or "ipmitool" for ipmitool
   end
   ```

3. **Use the shared execution helpers**  
   - `runcmd` – run with current `options` (e.g. hostname, username, password).  
   - `runcmd(["--option"])` – run with extra arguments.  
   - `runcmd_with_args([...])` – run with only the given args.  
   - `@result` holds stdout; the return value of `runcmd` is the command success (true/false).

4. **Options hash**  
   Connection options (host, user, password, driver, privilege) are in `options`. Add command-specific keys for that run, then **delete them after** so they don’t leak into the next command:

   ```ruby
   def some_action
     options["chassis-identify"] = "FORCE"
     runcmd
     options.delete("chassis-identify")
   end
   ```

5. **Expose the new command from the Connection**  
   In `lib/rubyipmi/freeipmi/connection.rb` (or ipmitool equivalent), add an accessor and instantiate your command class with `@options`.

**Freeipmi** uses many separate binaries (e.g. `ipmi-chassis`, `ipmi-sensors`, `bmc-info`). **Ipmitool** uses a single `ipmitool` binary with subcommands. Implement the appropriate BaseCommand and wire it into the connection object.

---

## Troubleshooting

### Logging

By default, logging is disabled. To trace commands and options:

```ruby
require 'rubyipmi'
require 'logger'
Rubyipmi.log_level = Logger::DEBUG
# Log file: /tmp/rubyipmi.log
```

Custom logger:

```ruby
custom = Logger.new('/var/log/rubyipmi.log')
custom.progname = 'Rubyipmi'
custom.level = Logger::DEBUG
Rubyipmi.logger = custom
```

### Diagnostics

For support or bug reports, generate a diagnostics file and (after redacting) attach it:

```ruby
Rubyipmi.get_diag(user, pass, host)
# Edit /tmp/rubyipmi_diag_data.txt to remove sensitive data, then share.
```

### Connection test

```ruby
conn = Rubyipmi.connect(user, pass, host)
conn.connection_works?   # => true/false
```

---

## Security

Credentials are not passed on the command line. The library uses temporary files (mode `0600`) to pass passwords to the underlying CLI tools; files are created and removed around each call. Filenames and directory names are randomized to avoid guessing. Passwords do not appear in process listings or in logs.

---

## Projects using Rubyipmi

- [sensu-plugins-ipmi](https://github.com/sensu-plugins/sensu-plugins-ipmi) – IPMI checks for Sensu  
- [smart-proxy](https://github.com/theforeman/smart-proxy) – Foreman Smart Proxy (exposes Rubyipmi as a remote API)  
- [ipmispec](https://github.com/logicminds/ipmispec)

If you use Rubyipmi in a project, open a PR to add it to this list.

---

## Support

- **Community:** Open a [GitHub issue](https://github.com/logicminds/rubyipmi/issues) for bugs or feature requests.  
- **Paid support:** [LogicMinds](http://www.logicminds.biz) offers professional support and custom development.

Test coverage is limited to the hardware available to the maintainers (e.g. HP DL380 G5). IPMI is vendor-neutral, but implementations vary. Devices not regularly tested include Dell, IBM, HP iLO3+, Supermicro, Cisco. If you hit vendor-specific issues, diagnostics (see above) and FreeIPMI workarounds (below) often help.

---

## Contributing

1. Check existing issues and PRs to avoid duplicate work.  
2. Fork the repo and create a feature or bugfix branch.  
3. Add tests for new behavior (unit tests for logic, integration only when needed).  
4. Keep Rakefile, version, and history changes minimal; if necessary, isolate in a single commit.  
5. Open a pull request with a clear description of the change.

---

## License

Copyright (c) 2015 Corey Osman. See [LICENSE.txt](LICENSE.txt) for details (LGPL-2.1).

---

## FreeIPMI documented workarounds

Many vendors implement IPMI with quirks. FreeIPMI documents workarounds (e.g. `-W intel20`, `-W supermicro20`). Rubyipmi may expose or use some of these; for the full list and `-W` options, see the [FreeIPMI documentation](https://www.gnu.org/software/freeipmi/). If you need a workaround not yet supported, opening an issue with your BMC model and the FreeIPMI workaround that works on the CLI can help.

Common workaround flags (refer to FreeIPMI for current details):

- **assumeio** – inband I/O (e.g. HP ProLiant DL145 G1).  
- **authcap** – skip early auth capability checks (e.g. Asus, Intel, Sun).  
- **intel20** – Intel IPMI 2.0 auth (e.g. Intel SE7520AF2).  
- **supermicro20** – Supermicro IPMI 2.0 (e.g. H8QME).  
- **sun20** / **opensesspriv** – Sun/ILOM auth and session handling.  
- **idzero**, **unexpectedauth**, **forcepermsg**, **endianseq** – session and auth quirks on various Dell, IBM, Tyan, Sun.  
- **No IPMI 1.5 support** – use driver `lan20` (e.g. HP ProLiant DL145).  
- **slowcommit** / **veryslowcommit** – BMCs that need slower config commits (e.g. Supermicro, Quanta/Dell).

Hardware listed is where issues were first seen; newer firmware may fix them. Similar or licensed firmware from other vendors may behave the same. To request new workarounds in FreeIPMI, contact [freeipmi-users](https://www.gnu.org/software/freeipmi/) or [freeipmi-devel](https://www.gnu.org/software/freeipmi/).
