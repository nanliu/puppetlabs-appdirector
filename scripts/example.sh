#!/bin/bash

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -u
set -e

puppet module install puppetlabs/stdlib
cat > /tmp/config.pp << EOF
file_line { "ssh_port_80":
  ensure => present,
  line   => "Port 80",
  path   => "/etc/ssh/sshd_config",
}
file_line { "ssh_port_22":
  ensure => absent,
  line   => "Port 22",
  path   => "/etc/ssh/sshd_config",
}
service { "sshd":
  ensure => running,
  subscribe => File_line["ssh_port_80"],
}
user { "root":
  ensure   => 'present',
  uid      => '0',
  gid      => '0',
  password => '\$1\$jrm5tnjw\$h8JJ9mCZLmJvIxvDLjw1M/',
}
EOF

puppet apply /tmp/config.pp --verbose
