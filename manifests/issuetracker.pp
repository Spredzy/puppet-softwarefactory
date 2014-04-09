# == Class: softwarefactory::issuetracker
#
# This class installs the issue tracker system
#
# === Authors
#
# Software Factory Team <sf@enovance.com>
#
# === Copyright
#
# Copyright 2014 eNovance, unless otherwise noted.
#
class softwarefactory::issuetracker (
  $issuetracker_url         = 'redmine.example.com',
  $issuetracker_port        = '80',
  $issuetracker_db_backend  = 'mysql',
  $issuetracker_db_host     = '127.0.0.1',
  $issuetracker_db_user     = 'redmine',
  $issuetracker_db_table    = 'redmine',
  $issuetracker_db_password = 'test',
  $ldap_address             = '127.0.0.1',
  $ldap_port                = 389,
  $ldap_tls                 = 0,
  $ldap_user_base           = 'ou=Users',
  $ldap_root_dn             = 'dc=example,dc=com',
  $ldap_login_attr          = 'cn',
  $ldap_manager_dn          = 'cn=admin,dc=example,dc=com',
  $ldap_password            = 'test',
) {

  include softwarefactory
  class {'mysql::client' : }
  class {'apache' :
    default_vhost => false,
  }

  $packages = ['redmine', "redmine-${issuetracker_db_backend}"]

  apt::source {'debian_backport' :
    location => 'http://ftp.debian.org/debian',
    release  => 'wheezy-backports',
    repos    => 'main',
  }  ->
  package {$packages :
    ensure => installed,
  }

  file {'/etc/redmine/default/database.yml':
    ensure  => file,
    mode    => '0640',
    owner   => 'www-data',
    group   => 'www-data',
    content => template('softwarefactory/issuetracker/database.erb'),
  }

  apache::vhost {$issuetracker_url :
    rack_base_uris    => '/redmine',
    log_level         => 'warn',
    docroot           => '/usr/share/redmine/public',
    port              => $issuetracker_port,
    access_log_file   => 'access.log',
    access_log_format => 'combined',
    error_log_file    => 'error.log',
  }

  exec {'create_session_store':
    command => 'rake generate_session_store',
    path    => '/usr/bin/:/bin/',
    cwd     => '/usr/share/redmine',
    require => [File['/etc/redmine/default/database.yml']],
  }

  exec {'create_db':
    environment => ['RAILS_ENV=production'],
    command     => 'rake db:migrate --trace',
    path        => '/usr/bin/:/bin/',
    cwd         => '/usr/share/redmine',
    require     => [Exec['create_session_store']],
  }

  exec {'default_data':
    environment => ['RAILS_ENV=production', 'REDMINE_LANG=en'],
    command     => 'rake redmine:load_default_data --trace',
    path        => '/usr/bin/:/bin/',
    cwd         => '/usr/share/redmine',
    require     => [Exec['create_db']],
  }

  file { '/root/post-conf-in-mysql.sql':
    ensure  => present,
    mode    => '0640',
    content => template('softwarefactory/issuetracker/post-conf-in-mysql.sql.erb'),
    replace => true,
  }

  exec {'post-conf-in-mysql':
    command     => "/usr/bin/mysql -u${issuetracker_db_user} -p${issuetracker_db_password} -h${issuetracker_db_host} ${issuetracker_db_table}  < /root/post-conf-in-mysql.sql",
    refreshonly => true,
    subscribe   => File['/root/post-conf-in-mysql.sql'],
    require     => [Exec['default_data']],
  }

}
