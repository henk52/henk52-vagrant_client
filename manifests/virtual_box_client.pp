# This manifest installs the VirtualBox Guest additions.

package { 'gcc':
  ensure => present,
}

package { 'kernel-devel':
  ensure => present,
}

package { 'kernel-headers':
  ensure => present,
}

package { 'dkms':
  ensure => present,
}

package { 'make':
  ensure => present,
}

package { 'bzip2':
  ensure => present,
}

package { 'perl':
  ensure => present,
}

# Install the 'vagrant' user
package { 'openssh':
  ensure => present,
  require => File [ 'repo_updates' ],
}

group { 'admin':
  ensure => present,
}

user { 'vagrant':
  ensure     => present,
  groups     => [ 'admin' ],
  managehome => true,
  home       => '/home/vagrant',
  comment    => 'Vagrant administrative user.'
  require    => Group [ 'admin' ],
}

file { '/home/vagrant/.ssh':
  ensure   => directory,
  owner    => 'vagrant',
  group    => 'vagrant',
  mode     => '750',
  require  => User [ 'vagrant' ],
}

exec { 'vagrant_rsa':
  creates  => '/home/vagrant/.ssh/id_rsa',
  command  => '/usr/bin/ssh-keygen -t rsa -b 2048  -q -f /home/vagrant/.ssh/id_rsa',
  user     => 'vagrant',
  group    => 'vagrant',
  require  => [
                User [ 'vagrant' ],
                Package [ 'openssh' ],
                File [ '/home/vagrant/.ssh' ],
              ],
}

# TODO V Make the content configurable, including enable to read it from  hiera.
file { '//home/vagrant/.ssh/authorized_keys':
  ensure  => present,
  require => File [ '/home/vagrant/.ssh' ],
  content => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key'
}

# Update the sudoers file.
file_line { 'no_defaults_requiretty':
  ensure => absent,
  line   => 'Defaults    requiretty',
  path   => '/etc/sudoers',
}

file_line { 'admin_without_passwd':
  ensure => present,
  line   => '%admin ALL=NOPASSWD: ALL',
  path   => '/etc/sudoers',
}

# Install the VirtualBox drivers etc.
file { '/var/puppetextras':
  ensure => directory,
}

exec { 'get_VBoxLinuxAdditions_run':
  creates => '/var/puppetextras/VBoxLinuxAdditions.run',
  command => '/usr/bin/wget --directory-prefix=/var/puppetextras http://10.1.233.3:/storage/puppet/VBoxLinuxAdditions.run',
  require => File [ '/var/puppetextras' ],
}
