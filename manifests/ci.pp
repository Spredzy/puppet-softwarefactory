# == Class: softwarefactory::ci
#
# This class installs the Continuous Integration system.
#
# === Authors
#
# Software Factory Team <sf@enovance.com>
#
# === Copyright
#
# Copyright 2014 eNovance, unless otherwise noted.
#
class softwarefactory::ci(
  $ldap_protocol         = 'ldap',
  $ldap_address          = '127.0.0.1',
  $ldap_root_dn          = 'dc=example,dc=com',
  $ldap_manager_dn       = 'cn=admin,dc=example,dc=com',
  $ldap_manager_password = 'test',
  $ldap_user_base        = 'ou=Users',
  $ldap_user_search      = 'cn={0}',
  $system_packages       = ['rubygems', 'rake', 'puppet-lint', 'python-pip'],
  $pip_packages          = ['flake8'],
  $gem_packages          = ['rspec-puppet', 'serverspec'],
) {

  include softwarefactory

  $ldap_url = "${ldap_protocol}://${ldap_address}"
  $base64_passwd = base64('encode', $ldap_manager_password)

  package {$system_packages :
    ensure => present,
  }
  package {$pip_packages :
    ensure   => present,
    provider => 'pip',
  }
  package {$gem_packages :
    ensure   => present,
    provider => 'gem',
  }

  class {'jenkins' :
    lts                => true,
    configure_firewall => false,
  }

  file {'/var/lib/jenkins/config.xml' :
    ensure  => present,
    mode    => '0644',
    owner   => 'jenkins',
    group   => 'nogroup',
    content => template('softwarefactory/ci/config.xml.erb'),
    notify  => Service['jenkins'],
  }

}
