### 0.11.0
This is a big update with many minor changes and bug fixes.  Thank you for all that submitted fixes.
- Removes jeweler dependency and replaces with bundler commands, updates gemspec
- Use HTTPS for homepage field in the gemspec
- Fix infinite loop when executing 'lan print' command
- The retry count counter is currently not incremented, so in the situation
  when this command fails, library enters infinite loop of executing this
  command, which is bad.

  Adds a missing counter incrementation with the same style as
  in basecommands and make it return current @info in case of a failure,
  so all methods accessing it will just get return nil.
 
- Leverage Enumerable#each_with_object
- Add a SensorsMixin to remove duplicate code
- Enable Rubocop GuardClause and fix complaints
- Remove duplicate methods
- Fixes "NoMethodError: undefined method `success?' for nil:NilClass"
- Some ruby versions need to require 'English' otherwise $CHILD_STATUS is nil
- Fix rubocop Style/MethodName "Use snake_case for method names."
- Rename private method
- Add deprecation warnings for two public methods
- Delete unused method
- Update .rubocop.yml accordingly
- Refactor duplicated chassis power command methods
- Adds additional rubycops
- Fixes many rubycop infractions
- Remove puppet code and vagrant
- Remove if / else logic and unnecessary return in #validate_status
- Reword confusing project description
- Update README.md section on booting to specific devices
- Update documentation around bootpxe, bootdisk functions 
- Remove pry statement from method
### 0.10.0
* gh-26 - make the driver default to lan20

Users of older IPMI devices will now need to pass the specified driver type.

### 0.9.3
* normalize the options being passed into the connect method

### 0.9.2
* fixes an issue where is_provider_installed? should only return a boolean value instead of raising and error
* fixes a minor style issue where providers_installed? was returning an array when a boolean might have been expected

### 0.9.1
* fixes an issue with connection_works? api call when command raises an error

### 0.9.0
* move to rspec3 syntax
* added logging capabilities
* fix freeipmi lan issue with auto driver type not being loaded
* refactor get_diag function to be useful
* remove 1.9.2 support from travis matrix

### 0.8.1
* switch to LGPL license
* remove rcov in favor of simplecov

### 0.8.0
* changed License from GPL to LGPL
* added option to specify privilge-level
