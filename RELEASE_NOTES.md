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
* gh-24 allow openipmi to be used
* refactored some tests
* refactored connection and connect

### 0.8.1
* switch to LGPL license
* remove rcov in favor of simplecov

### 0.8.0
* changed License from GPL to LGPL
* added option to specify privilege-level
