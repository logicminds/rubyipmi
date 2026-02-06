# GitHub Copilot Instructions for Rubyipmi

## Project Overview

Rubyipmi is a Ruby library that wraps **freeipmi** and **ipmitool** command-line tools behind a consistent, object-oriented API. It provides Ruby programmers with a clean interface to control and query BMC (Baseboard Management Controller) devices without shelling out or parsing CLI output manually.

## Architecture

### Dual-Provider Pattern
- Supports both **freeipmi** and **ipmitool** backends
- Auto-detects which provider is installed, or can be explicitly specified
- Each provider has its own command hierarchy under `lib/rubyipmi/freeipmi/` and `lib/rubyipmi/ipmitool/`

### Command-Based Architecture
- Each IPMI operation is implemented as a command class
- Commands inherit from provider-specific BaseCommand classes:
  - `Rubyipmi::Freeipmi::Commands::BaseCommand`
  - `Rubyipmi::Ipmitool::Commands::BaseCommand`
- BaseCommand handles command execution, credential management, and error handling

### Connection Objects
- Connection classes (`Freeipmi::Connection`, `Ipmitool::Connection`) wire up commands
- Expose commands via accessor methods (e.g., `conn.chassis.power.on`)
- Share `@options` hash containing credentials and connection parameters across all commands

## Security Requirements (CRITICAL)

**Credential handling is paramount. Follow these rules strictly:**

1. **Never pass credentials on the command line** - they would appear in process listings
2. **Use temporary files (mode 0600)** for password passing to CLI tools
3. **Randomize file and directory names** to prevent enumeration attacks
4. **Exclude credentials from logs** - they must not appear in debug output or process listings
5. **Clean up temporary files immediately** after use
6. **Redact sensitive data** in diagnostics output before sharing

See `lib/rubyipmi/commands/basecommand.rb` for the `setpass` pattern used to securely pass credentials.

## Coding Patterns

### Adding a New Command

1. **Subclass the appropriate BaseCommand**:
```ruby
module Rubyipmi::Freeipmi
  class MyCommand < BaseCommand
    def initialize(opts = {})
      @options = opts
      super("ipmi-chassis", opts)  # CLI tool name
    end
  end
end
```

2. **Use execution helpers**:
   - `runcmd` - Run with current `@options`
   - `runcmd(["--extra-arg"])` - Run with additional arguments
   - `runcmd_with_args([...])` - Run with only specified arguments
   - `@result` holds stdout after execution
   - Return value indicates success/failure

3. **Handle command-specific options**:
```ruby
def some_action
  options["chassis-identify"] = "FORCE"
  runcmd
  options.delete("chassis-identify")  # Clean up after!
end
```

4. **Expose from Connection**:
   - Add accessor in `lib/rubyipmi/freeipmi/connection.rb` (or ipmitool equivalent)
   - Instantiate with shared `@options`

### Provider Differences

- **Freeipmi**: Uses multiple separate binaries (`ipmi-chassis`, `ipmi-sensors`, `bmc-info`, etc.)
- **Ipmitool**: Uses single `ipmitool` binary with subcommands

## Code Style & Standards

### RuboCop Configuration
- Hash syntax: Use hash rockets (`:key => value`)
- String literals: Both single and double quotes allowed
- Class check: Use `kind_of?` not `is_a?`
- Hash literal braces: No spaces inside (`{:key => value}`)
- Line length: Max 149 characters
- See `.rubocop.yml` for complete configuration

### Ruby Version
- **Required**: Ruby 3.0+ (tested through 3.4)
- Use modern Ruby features but maintain compatibility with Ruby 3.0

### Documentation
- RDoc for public APIs
- Code comments for complex logic or security-critical sections
- Module documentation not required (disabled in RuboCop)

## Testing Standards

### Unit Tests
- Located in `spec/unit/`
- Use mocks and stubs - **no real BMC required**
- Run with: `bundle exec rake unit`
- Must not make actual IPMI calls

### Integration Tests
- Located in `spec/integration/`
- Require real BMC hardware
- **Warning**: These tests WILL power cycle devices!
- **Never run on production systems**
- Run with: `bundle exec rake integration ipmiuser=USER ipmipass=PASS ipmihost=HOST ipmiprovider=freeipmi`

### Test Organization
- Use RSpec
- Follow patterns in existing specs
- Mock command execution at the BaseCommand level for unit tests
- Validate both success and error paths

## Dependencies

### Runtime
- `observer` - For logging and observability
- `logger` - Standard library logging

### Development
- `rspec` - Testing framework
- `rubocop` - Code style enforcement
- `rake` - Task automation
- `bundler` - Dependency management

## Common Patterns

### Logging
```ruby
require 'rubyipmi'
require 'logger'
Rubyipmi.log_level = Logger::DEBUG
# Creates /tmp/rubyipmi.log
```

### Error Handling
- Freeipmi commands use `ErrorCodes` hash for known error patterns
- `find_fix` method recursively applies fixes from error codes
- Commands may retry with modified options based on error feedback

### Dynamic Methods
- Sensors use `method_missing` to expose sensor names as methods
- FRU commands dynamically parse and expose FRU fields
- See `lib/rubyipmi/commands/mixins/sensors_mixin.rb` for patterns

## File Structure

```
lib/rubyipmi/
├── rubyipmi.rb              # Main entry point, connection factory
├── commands/
│   ├── basecommand.rb       # Shared base class
│   └── mixins/              # Shared behavior mixins
├── freeipmi/
│   ├── connection.rb        # Freeipmi connection class
│   ├── errorcodes.rb        # Known error patterns and fixes
│   └── commands/            # Freeipmi command implementations
│       ├── basecommand.rb   # Freeipmi-specific base
│       ├── chassis.rb       # Chassis control
│       ├── power.rb         # Power management
│       ├── sensors.rb       # Sensor monitoring
│       └── ...
└── ipmitool/
    ├── connection.rb        # Ipmitool connection class
    └── commands/            # Ipmitool command implementations
        └── ...
```

## CI/CD

### GitHub Actions Workflows
- **test.yml**: Unit tests and gem build (Ruby 3.0–3.4)
- **lint.yml**: RuboCop style checks
- **codeql.yml**: Security and code quality analysis
- **security.yml**: Dependency review and bundler-audit

### Dependabot
- Configured in `.github/dependabot.yml`
- Weekly updates for dependencies and GitHub Actions
- Security alerts appear in Security tab

## Additional Notes

### IPMI Provider Workarounds
- Many BMC vendors have IPMI quirks requiring workarounds
- Freeipmi documents these (e.g., `-W intel20`, `-W supermicro20`)
- See "FreeIPMI documented workarounds" section in README.md
- May need to expose or implement workaround flags for specific hardware

### Diagnostics
- `Rubyipmi.get_diag(user, pass, host)` creates diagnostics file
- Writes to `/tmp/rubyipmi_diag_data.txt`
- **Always redact sensitive data** (IPs, MACs, credentials) before sharing

### Projects Using Rubyipmi
- sensu-plugins-ipmi
- Foreman Smart Proxy
- ipmispec

Understanding these integrations helps guide API design decisions.
