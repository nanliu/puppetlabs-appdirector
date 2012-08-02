# VMware vFabric Application Director Puppet Service

![Puppet Labs Logo](http://www.puppetlabs.com/wp-content/uploads/2010/12/Puppet-Labs-Logo-Horizontal-Sm.png)

## Overview

Puppet Labs provides an integration solution for [VMware vFabric Application Director](http://www.vmware.com/products/application-platform/vfabric-application-director/overview.html). The Puppet service enables Application Director customers to deploy applications via puppet manifests or deploy Application Director blueprints using existing Puppet modules available on the [Puppet Forge](http://forge.puppetlabs.com/). The solution levarages the Application Director management console to configure Puppet classes and utilize Puppet Forge modules to deploy services and create Application Director blueprints.

## Puppet Modules as Application Director Blueprints

Deploying Puppet modules as blueprints in VMware vFabric Application Director environments consist of the follow steps.

* Install and setup Puppet service.
* Download and translate Puppet module.
* Install and setup application service.
* Configure and deploy application blueprint.

## Module Installation

The github module only needs to be installed on the Application Director management console. The repo provides some example scripts as well as a translation utility to map Puppet modules to Application Director compatible service scripts.

Requirements: Puppet Enterprise 2.5.0+ or Ruby 1.8.7 and Puppet Open Source 2.7.14+.

Installation:

* git clone https://github.com/puppetlabs/puppetlabs-appdirector.git

## Puppet Service

Users have a choice of installing Puppet Enterprise or Puppet Community as a service in the Application Director environment. Both installation scripts only deploy puppet agent.

### Puppet Enterprise

1. Create new service in the catalog.
2. Use the following values:
       * Name: PuppetEnterprise
       * Version: 2.5.3
       * Tags: "Other"
       * Supported OSes: See PuppetLabs Website.
       * Supported Components: script.
3. Add scripts/puppet_enterprise.sh to the service install lifecycle.
4. Add global_conf properties with the value: https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf (see global_conf.png)
5. Add installer_payload properties with the approriate package for the operating system: https://pm.puppetlabs.com/puppet-enterprise/2.5.3/
6. Add puppet_server properties with the approriate puppet master name, otherwise defaults to 'puppet'.
7. Add agent_cert properties with the systems certificate name, otherwise defaults to the hostname.

### Puppet Community

1. Create new service in the catalog.
2. Use the following values:
       * Name: Puppet
       * Version: 2.7
       * Tags: "Other"
       * Supported OSes: Any Operating System in RHEL and Debian OS family.
       * Supported Components: script.
3. Add scripts/puppet_community.sh to service install lifecycle.
4. Add the global_conf properties with the value: https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf (see global_conf.png)

## Puppet Modules

There's more than 400 modules at [Puppet Forge](http://forge.puppetlabs.com/) and they can be used to deploy a wide variety of popular applications. The example below describes the process of deploying mysql module; however, any other module can be used. For complex modules, please visit the [Puppet Forge](http://forge.puppetlabs.com/) for usage examples and documentation.

1. Search and install modules

        $ puppet module search puppetlabs
        Searching http://forge.puppetlabs.com ...
        NAME                             DESCRIPTION                                                                               AUTHOR        KEYWORDS                                    
        puppetlabs-apache                This is a generic Apache module that includes support for creating VirtualHosts.          @puppetlabs   apache web virtualhost                      
        puppetlabs-collectd              This is a module for managing the Collectd statistical collection daemon.                 @puppetlabs   collectd statistics RRD                     
        puppetlabs-vcsrepo               A module that provides the vcsrepo type and providers.                                    @puppetlabs   vcs repo svn subversion git hg bzr CVS      
        puppetlabs-gcc                   Module to manage gcc                                                                      @puppetlabs   gcc compiler                     
        ...
        $ puppet module install puppetlabs-mysql
        Preparing to install into /Users/nan/.puppet/modules ...
        Downloading from http://forge.puppetlabs.com ...
        Installing -- do not interrupt ...
        /Users/tom/.puppet/modules
        └── puppetlabs-mysql (v0.4.0)

2. Create a new service in the catalog.
3. Use the puppet module name and version for the new service (see module documentation for OS support).

        * Name: MySQL
        * Version: 0.4.0
        ...

4. List available puppet classes:

        $ ./bin/appdirector_module.rb
        Available Puppet Classes:
        mysql
        mysql::backup
        mysql::config
        mysql::java
        mysql::params
        mysql::python
        mysql::ruby
        mysql::server
        mysql::server::account_security
        mysql::server::monitor
        mysql::server::mysqltuner

5. Generate appdirector service script for mysql puppet class:

        $ ./bin/appdirector_module mysql
        #!/bin/bash
        
        . $global_conf
        
        export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        
        set -u
        set -e
        
        puppet module install puppetlabs/mysql
        
        cat > /tmp/mysql.pp <<EOF
        class { 'mysql':
         package_ensure => $package_ensure,
         package_name   => $package_name,
        }
        EOF
        puppet apply --verbose /tmp/mysql.pp

6. Add any puppet class parameters as properties with the type string and default value of undef (do not quote).
      * name: package_ensure, type: string, default: undef
      * name: package_name, type: string, default: undef
7. Add the global_conf properties with the value: https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf (see global_conf.png)
8. Create a new blueprint for MySQL.
9. Add Puppet service.
10. Add MySQL service.
11. Create dependency between MySQL and Puppet service.
12. Deploy application.

One of the benefits of deploying Puppet in Application Director environment, is Puppet's ability to manage resources. For example, once the mysql module is deployed, Application Director users can describe and deploy mysql databases using the following puppet manifest:

    mysql::db { 'mydb':
      user     => 'myuser',
      password => 'mypass',
      host     => 'localhost',
      grant    => ['all'],
    }

## Examples

In the sections below, we will provide step-by-step instructions for deploying Jenkins, and a custom Puppet manifest.

### Deploying Jenkins

Deploying jenkins

* Install rtyler/jenkins module from forge:

        $ puppet module install rtyler/jenkins
        Preparing to install into /Users/nan/.puppet/modules ...
        Downloading from http://forge.puppetlabs.com ...
        Installing -- do not interrupt ...
        /Users/tom/.puppet/modules
        └── rtyler-jenkins (v0.2.3)

* Create new service in the catalog:

        * Name: Jenkins
        * Version: 0.2.3
        ...

* Generate appdirector service script for jenkins puppet class:

        $ ./bin/appdirector_module jenkins
        #!/bin/bash
        
        . $global_conf
        
        export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        
        set -u
        set -e
        
        puppet module install rtyler/jenkins
        
        cat > /tmp/jenkins.pp <<EOF
        class { 'jenkins':
        
        }
        EOF
        puppet apply --verbose /tmp/jenkins.pp
* Add the global_conf properties with the value: https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf (see global_conf.png)
* Create a new blueprint for Jenkins
* Add Puppet and Jenkins service.
* Create dependency between Jenkins and Puppet service.
* Deploy application.

### Custom Puppet Manifests

Once Puppet's service is created, Application Director can also deploy custom manifests. Use the scripts/puppet_manifests.sh as a template and add any puppet manifests in the appropriate section. The scripts/example.sh provides an example where ssh service is changed to port 80, restarts sshd as necessary, and enforces a specific root user password.
