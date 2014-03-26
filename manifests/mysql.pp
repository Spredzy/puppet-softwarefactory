# == Class: softwarefactory::mysql
#
# This class installs the Gerrit code-review system
#
# === Authors
#
# Software Factory Team <sf@enovance.com>
#
# === Copyright
#
# Copyright 2014 eNovance, unless otherwise noted.
#
class softwarefactory::mysql {

  include softwarefactory

  $databases = {
    'redmine'             => {
      ensure  => 'present',
      charset => 'utf8',
    },
    'gerrit'              => {
      ensure  => 'present',
      charset => 'utf8',
    },
  }

  $users = {
    'gerrit@%'                                           => {
      ensure                   => 'present',
      max_connections_per_hour => '0',
      max_queries_per_hour     => '0',
      max_updates_per_hour     => '0',
      max_user_connections     => '0',
      password_hash            => '*94BDCEBE19083CE2A1F959FD02F964C7AF4CFC29', # pwd: test
    },
    'redmine@%'                                          => {
      ensure                   => 'present',
      max_connections_per_hour => '0',
      max_queries_per_hour     => '0',
      max_updates_per_hour     => '0',
      max_user_connections     => '0',
      password_hash            => '*94BDCEBE19083CE2A1F959FD02F964C7AF4CFC29', #pwd: test
    },
  }

  $grants = {
    'gerrit@%/gerrit.*'                  => {
      ensure     => 'present',
      options    => ['GRANT'],
      privileges => ['ALL'],
      table      => 'gerrit.*',
      user       => 'gerrit@%',
    },
    'redmine@%/redmine.*'                => {
      ensure     => 'present',
      options    => ['GRANT'],
      privileges => ['ALL'],
      table      => 'redmine.*',
      user       => 'redmine@%',
    },
  }

  class {'::mysql::server':
    root_password => 'password',
    users         => $users,
    grants        => $grants,
    databases     => $databases,
  }

}
