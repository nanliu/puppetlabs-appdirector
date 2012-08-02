#! /bin/bash
set -x
set -e
set -u

# Figure out if we have wget or curl
if which wget >/dev/null; then
  http_get="wget --output-document=- --quiet"
elif which curl >/dev/null; then
  http_get="curl -o -"
else
  yum -y install curl
  http_get="curl -o -"
fi

currentdir=`pwd`

# The installer action determines a temporary directory internally
# This is not a user defined option.  You may assume this will be
# a unique string of characters.
tmpdir=/var/tmp/
cd "${tmpdir}"

echo "Installation script has started..."
echo "Downloading from: ${installer_payload}"

# Create a new directory to decompress the Puppet Enterprise installer
# into.  This provides us with consistent pathing regardless of the PE
# version.
install_dir="puppet-enterprise"
if [[ ! -e "${install_dir}" ]]; then
  mkdir "${install_dir}"
fi

cat > puppet.answers << EOF
q_fail_on_unsuccessful_master_lookup=n
q_install=y
q_puppet_cloud_install=n
q_puppet_enterpriseconsole_install=n
q_puppet_symlinks_install=y
q_puppetagent_install=y
q_puppetagent_certname=`hostname`
q_puppetagent_server=$puppet_server
q_puppetca_install=n
q_puppetmaster_install=n
q_vendor_packages_install=y
EOF

# We assume the payload is a tar.gz file because the option handler
# enforces this.
# To save disk space (I'm concerned about /tmp filling) decompress on the fly.
echo "Uncompressing the payload ..."
$http_get "${installer_payload}" | \
  tar -xvzf - --strip-components 1 -C "${install_dir}"
# REVISIT (This assumes GNU tar with the --strip-components option)
echo "Uncompressing the payload ... Done."

# Install Puppet Enterprise
"${install_dir}"/puppet-enterprise-installer -a puppet.answers 2>&1 | tee install.log

# And then kick off a puppet agent run
/opt/puppet/bin/puppet agent --daemonize \
  --onetime \
  --ignorecache \
  --no-usecacheonfailure \
  --detailed-exitcodes \
  --no-splay
