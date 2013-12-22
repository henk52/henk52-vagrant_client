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



