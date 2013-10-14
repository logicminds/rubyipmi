$packages_installed = ['libgcrypt-devel', 'ipmitool', 'gcc', 'make', 'ruby-devel']
$freeipmi_version = '1.3.2'
$freeipmi_name     = "freeipmi-${freeipmi_version}"
$freeipmi_dir      = "/opt/${freeipmi_name}"
$directories_created = ['/opt']
$gems_installed = ['bundler']
$rubyipmi_dir = '/rubyipmi'
archive { "freeipmi-${freeipmi_version}":
  ensure => present,
  url    => "http://ftp.gnu.org/gnu/freeipmi/freeipmi-${freeipmi_version}.tar.gz",
  target => '/opt',
  checksum => false,
  before => Exec["configure_freeipmi"],
  require => File['/opt'],
  src_target => '/opt'
}
Exec{
  path => ['/usr/bin/', '/sbin', '/bin', '/usr/local/bin', '/usr/local/sbin', '/usr/sbin']
}
package{$gems_installed:
  ensure => present,
  provider => 'gem',
  before => Exec["configure_freeipmi"]
}
package{$packages_installed:
  ensure => present,
  before => Exec["configure_freeipmi"]
}
file{$directories_created:
  ensure => directory,
  before => Exec['configure_freeipmi']
}
exec{"configure_freeipmi":
    cwd     => $freeipmi_dir,
    command => "bash ${freeipmi_dir}/configure",
    creates => "${freeipmi_dir}/ipmipower/ipmipower",
    before  => Exec["install_freeipmi"]
}
exec{"install_freeipmi":
  cwd     => $freeipmi_dir,
  command => "make install",
  creates => "/usr/local/sbin/ipmipower"
}

exec{"bundle install":
  cwd     => $rubyipmi_dir,
  creates => "${rubyipmi_dir}/Gem.lock"


}