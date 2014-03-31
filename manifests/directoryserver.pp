# == Class: softwarefactory::directoryserver
#
# This class installs the OpenLDAP directory server
#
# === Authors
#
# Software Factory Team <sf@enovance.com>
#
# === Copyright
#
# Copyright 2014 eNovance, unless otherwise noted.
#
class softwarefactory::directoryserver (
  $ldap_root_dn    = 'dc=example,dc=com',
  $ldap_manager_dn = 'cn=admin,dc=example,dc=com',
  $ldap_password   = 'test',
) {

  include softwarefactory
  include ldap

  Exec {
    path =>  ['/usr/local/sbin','/usr/local/bin','/usr/sbin','/usr/bin','/sbin','/bin'],
  }

  class {'ldap::server::master' :
    suffix => $ldap_root_dn,
    rootpw => '{SSHA}sYdHFDbadO2r5CCcmygXfC81TdmtmD7X', #pwd: test
  } ->
  file {'/tmp/organization.ldif' :
    source => 'puppet:///modules/softwarefactory/ldap/organization.ldif',
  } ->
  file {'/tmp/users_ou.ldif' :
    source => 'puppet:///modules/softwarefactory/ldap/users_ou.ldif',
  } ->
  file {'/tmp/users.ldif' :
    source => 'puppet:///modules/softwarefactory/ldap/users.ldif',
  } ->
  file {'/tmp/groups_ou.ldif' :
    source => 'puppet:///modules/softwarefactory/ldap/groups_ou.ldif',
  } ->
  file {'/tmp/groups.ldif' :
    source => 'puppet:///modules/softwarefactory/ldap/groups.ldif',
  } ->
  exec { "ldapadd -x -D ${ldap_manager_dn} -w ${ldap_password} -f /tmp/organization.ldif" :
    unless => "ldapsearch -x -D ${ldap_manager_dn} -b ${ldap_root_dn} -w ${ldap_password} | grep 'objectClass: organization'"
  } ->
  exec { "ldapadd -x -D ${ldap_manager_dn} -w ${ldap_password} -f /tmp/users_ou.ldif" :
    unless => "ldapsearch -x -D ${ldap_manager_dn} -b ${ldap_root_dn} -w ${ldap_password} | grep 'dn: ou=Users'"
  } ->
  exec { "ldapadd -x -D ${ldap_manager_dn} -w ${ldap_password} -f /tmp/users.ldif" :
    unless => "ldapsearch -x -D ${ldap_manager_dn} -b ${ldap_root_dn} -w ${ldap_password} | grep 'objectClass: person'"
  } ->
  exec { "ldapadd -x -D ${ldap_manager_dn} -w ${ldap_password} -f /tmp/groups_ou.ldif" :
    unless => "ldapsearch -x -D ${ldap_manager_dn} -b ${ldap_root_dn} -w ${ldap_password} | grep 'dn: ou=Groups'"
  } ->
  exec { "ldapadd -x -D ${ldap_manager_dn} -w ${ldap_password} -f /tmp/groups.ldif" :
    unless => "ldapsearch -x -D ${ldap_manager_dn} -b ${ldap_root_dn} -w ${ldap_password} | grep 'objectClass: group'"
  }

}
