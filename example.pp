class {'softwarefactory::directoryserver' :
} ->
class {'softwarefactory::mysql' : } ->
class {'softwarefactory::codereview' :
  httpd_hostname  => $::ipaddress,
} ->
class {'softwarefactory::ci' :
} ->
class {'softwarefactory::issuetracker' :
}
