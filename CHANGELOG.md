# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] 
- Drop support for testing ruby 2.x #66
- Adds experimental testing support for ruby 4.0

## [0.12.1]  - 2026

### Fixed
- Don't re-raise the original exception in basecommand
- Properly mock capture3 API which returns a Process::Status, not true
- Don't fail when status was success
- Strip `which` output like it was before the Ruby 3.0 changes

### Changed
- Update link to sensu ipmi plugin

## [0.12.0] - 2024

### Added
- Ruby 3.4 support
- GitHub Actions for CI/CD testing
- Logger gem dependency (will be removed in Ruby 3.5)

### Changed
- Test on Ruby 3.1, 3.2 & 3.3
- Fix tests for Ruby 3.0
- Update actions/checkout to v4
- Remove highline as a runtime dependency
- Simplify gemspec and Gemfile
- Use SPDX license code in gemspec
- Limit dependency ranges to avoid gemspec warnings
- Let git ignore *.gem files

## [0.11.1] - 2023

### Fixed
- Exclude hidden files from the gem package

## [0.11.0] - 2023

### Added
- SensorsMixin to remove duplicate code
- Rubocop GuardClause support
- Additional rubocop cops

### Changed
- Remove jeweler dependency, replace with bundler commands
- Use HTTPS for homepage field in gemspec
- Leverage Enumerable#each_with_object
- Move #drivers_map to a constant
- Update .rubocop.yml
- Reword confusing project description
- Update README.md section on booting to specific devices
- Remove puppet code and vagrant

### Fixed
- Fix infinite loop when executing 'lan print' command
- Fix "NoMethodError: undefined method `success?' for nil:NilClass"
- Fix rubocop Style/MethodName "Use snake_case for method names"
- Remove duplicate methods
- Remove if/else logic and unnecessary return in #validate_status
- Remove pry statement from method
- Fix many rubocop style infractions

## [0.10.0] - 2022

### Changed
- Make the driver default to lan20 (users of older IPMI devices will need to pass the specified driver type)

## [0.9.3] - 2022

### Fixed
- Normalize the options being passed into the connect method

## [0.9.2] - 2022

### Fixed
- Fix issue where is_provider_installed? should only return a boolean value instead of raising an error
- Fix minor style issue where providers_installed? was returning an array when a boolean might have been expected

### Changed
- Updated README about support and added TOC

## [0.9.1] - 2022

### Fixed
- Fix issue with connection_works? API call when command raises an error

### Changed
- Updated README and release notes
- Fix spelling mistakes

## [0.9.0] - 2022

### Added
- Ability to generate a logfile
- Ability to test connection
- Coveralls support for coverage data

### Changed
- Move to rspec3 expect syntax
- Refactor get_diag function to be useful
- Remove 1.9.2 support and add 2.2 support
- Updated .gitignore to stop watching Gemfile.lock
- Updated spec tests to load spec_helper differently
- Removed development support for Ruby 1.8

### Fixed
- Fix issue with freeipmi lan info and auto fix
- Fix issue with options not being deleted for fru

## [0.8.1] - 2021

### Changed
- Switch to LGPL license
- Remove rcov in favor of simplecov
- Updated gemspec and removed rcov from Gemfile
- Added new rubies to travis testing suite

## [0.8.0] - 2021

### Added
- Option to specify privilege level
- Support for multiple driver-types
- Flexible options hash

### Changed
- Changed License from GPL to LGPL
- Refactored new opts hash feature
- Added unit tests for opts hash feature
- Updated README

### Fixed
- Fix ipmitool power.on precheck

## [0.7.0] - 2020

### Added
- Debug option (set rubyipmi_debug=true environment variable)
- Attribute reader for result to retrieve from outside classes
- Travis CI support

### Changed
- Updated gemspec files
- Updated README
- Removed development support for Ruby 2.0.0

### Fixed
- Fix bug where command was returning the value and not the result
- Fix bug where bmc-config was not raising an error when errors occurred
- Fix issues with freeipmi not getting right error code
- Updated unit tests for error code checking
- Updated ipmitool spec tests and fixed error code search functionality

## [0.6.0] - 2020

### Added
- Support for using bmc reset

### Changed
- Default connection for ipmitool now uses IPMI 2.0
- Updated license

## [0.5.1] - 2020

### Fixed
- Fix loading error in rbenv environment

### Changed
- Updated README

## [0.5.0] - 2020

### Added
- FRU (Field Replaceable Unit) support
- Hidden password security
- Printdiag function

## [0.4.0] - 2020

### Added
- Sensor support

### Changed
- Renamed subnet function to netmask function

## [0.3.3] - 2020

### Changed
- Updated error output

## [0.3.2] - 2020

### Fixed
- Fix issue with commands not returning value

## [0.3.1] - 2020

### Fixed
- Fix issue with ipmitool identify

## [0.3.0] - 2020

### Added
- Makecommand function
- BMC lan info
- Boot settings

### Changed
- Updated tests and lan parser

### Fixed
- Fix error with getting info object

## [0.2.0] - 2020

### Added
- BMC info function

### Changed
- Updated tests

## [0.1.1] - 2020

### Fixed
- Fix issue with power cycle when system is off

### Changed
- Updated tests

## [0.1.0] - 2020

### Added
- Initial release with ruby-freeipmi and ipmitool code support
