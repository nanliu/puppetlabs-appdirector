#!/bin/bash

set -e
set -u

# Installs Ruby 1.8.7
printf %s '[kbs-el5-rb187]
name=kbs-el5-rb187
enabled=1
baseurl=http://centos.karan.org/el$releasever/ruby187/$basearch/
gpgcheck=1
gpgkey=http://centos.karan.org/RPM-GPG-KEY-karan.org.txt
' > /etc/yum.repos.d/kbsingh-CentOS-Ruby.repo

yum install -y ruby

# Installs dependencies and Puppet
printf %s '[puppetlabs-products]
name=Puppet Labs Products $releasever - $basearch
baseurl=http://yum.puppetlabs.com/el/$releasever/products/$basearch
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
enabled=1
gpgcheck=1

[puppetlabs-deps]
name=Puppet Labs Dependencies $releasever - $basearch
baseurl=http://yum.puppetlabs.com/el/$releasever/dependencies/$basearch
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
enabled=1
gpgcheck=1

[puppetlabs-products-source]
name=Puppet Labs Products $releasever - $basearch - Source
baseurl=http://yum.puppetlabs.com/el/$releasever/products/SRPMS
gpgkey=file:///yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
failovermethod=priority
enabled=0
gpgcheck=1

[puppetlabs-deps-source]
name=Puppet Labs Source Dependencies $releasever - $basearch - Source
baseurl=http://yum.puppetlabs.com/el/$releasever/dependencies/SRPMS
gpgkey=file:///yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
enabled=0
gpgcheck=1
' > /etc/yum.repos.d/puppetlabs.repo

yum install -y facter puppet
