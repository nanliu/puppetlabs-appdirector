#!/bin/bash

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -u
set -e

puppet module install puppetlabs/stdlib
cat > /tmp/manifests.pp << EOF
# Insert user custom manifests below:

EOF

puppet apply /tmp/manifests.pp --verbose
