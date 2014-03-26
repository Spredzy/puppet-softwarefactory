# == Class: softwarefactory::gerrit
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
class softwarefactory::codereview (
  $codereview_home           = '/opt/gerrit',
  $codereview_source         = '/tmp/gerrit-2.8.1.war',
  $codereview_auth_type      = 'ldap',
  $database_backend          = 'mysql',
  $database_hostname         = '127.0.0.1',
  $database_name             = 'gerrit',
  $database_username         = 'gerrit',
  $database_password         = 'test',
  $httpd_port                = 8085,
  $httpd_protocol            = 'http',
  $httpd_hostname            = 'gerrit.example.com',
  $download_scheme           = ['ssh'],
  $ldap_protocol             = 'ldap',
  $ldap_address              = '127.0.0.1',
  $ldap_root_dn              = 'dc=example,dc=com',
  $ldap_manager_dn           = 'cn=admin,dc=example,dc=com',
  $ldap_manager_password     = 'test',
  $ldap_user_base            = 'ou=Users',
  $ldap_account_pattern      = '(&(objectClass=inetOrgPerson)(cn=\${username}))',
  $ldap_account_emailaddress = 'mail',
  $ldap_account_sshusername  = 'cn',
){

  include softwarefactory

  exec {"/usr/bin/wget -O ${codereview_source} 'http://gerrit-releases.storage.googleapis.com/gerrit-2.8.1.war'":
    unless => "/bin/ls $codereview_source}"
  } ->
  class {'gerrit' :
    source                   => $codereview_source,
    target                   => $codereview_home,
    auth_type                => $codereview_auth_type,
    database_backend         => $database_backend,
    database_hostname        => $database_hostname,
    database_name            => $database_name,
    database_username        => $database_username,
    database_password        => $database_password,
    canonicalweburl          => "${httpd_protocol}://${httpd_hostname}:${httpd_port}",
    httpd_port               => $httpd_port,
    httpd_protocol           => $httpd_protocol,
    httpd_hostname           => $httpd_hostname,
    download_scheme          => $download_scheme,
    ldap_server              => "${ldap_protocol}://${ldap_address}",
    ldap_username            => $ldap_manager_dn,
    ldap_accountbase         => "${ldap_user_base},${ldap_root_dn}",
    ldap_accountpattern      => $ldap_account_pattern,
    ldap_accountemailaddress => $ldap_account_emailaddress,
    ldap_accountsshusername  => $ldap_account_sshusername,
    ldap_password            => $ldap_manager_password,
  } ->
  gerrit::hook { 'patchset-created' :
    source => 'puppet:///modules/softwarefactory/codereview/hooks/patchset-created',
  } ->
  gerrit::hook { 'change-merged' :
    source => 'puppet:///modules/softwarefactory/codereview/hooks/change-merged',
  } ->
  gerrit::plugin {'replication.jar' :
    source => 'puppet:///modules/softwarefactory/codereview/plugins/replication.jar',
  } ->
  gerrit::plugin {'delete-project.jar' :
    source => 'puppet:///modules/softwarefactory/codereview/plugins/delete-project.jar',
  }

}
