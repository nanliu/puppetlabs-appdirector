#!/bin/bash

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -u
set -e

puppet module install --force puppetlabs/stdlib

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
  ensure    => running,
  enable    => true,
  subscribe => File_line["ssh_port_80", "ssh_port_22"],
}
user { "root":
  ensure   => 'present',
  uid      => '0',
  gid      => '0',
  password => '\$1\$jrm5tnjw\$h8JJ9mCZLmJvIxvDLjw1M/',
}
EOF

puppet apply --verbose --no-color /tmp/config.pp
