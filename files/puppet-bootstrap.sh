#!/bin/bash

set -e
set -u

printf %s "\
[puppetlabs]
name=Puppet Labs Packages
baseurl=http://yum.puppetlabs.com/base/
enabled=1
gpgcheck=1
gpgkey=http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
" > /etc/yum.repos.d/puppetlabs.repo

yum install -y facter puppet
