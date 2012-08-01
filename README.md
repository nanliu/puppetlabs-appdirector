# Puppet Labs AppDirector

![Puppet Labs Logo](http://www.puppetlabs.com/wp-content/uploads/2010/12/Puppet-Labs-Logo-Horizontal-Sm.png)

## Overview

Puppet Labs AppDirector module provides an integration solution for [VMware vFabric Application Director](http://www.vmware.com/products/application-platform/vfabric-application-director/overview.html). The Puppet service enables AppDirector customers to utilize any puppet manifests or deploy AppDirector blueprints based on puppet module available on [Puppet Forge](http://forge.puppetlabs.com/). The solution levarages AppDirector management console to configure Puppet classes and deploy solutions for VM

## Puppet Module Deployments

Deploying Puppet module in AppDirector environment consist of the follow steps.

* download puppetlabs-appdirector.
* deploy Puppet service.
* download and translate Puppet module.
* deploy application service.
* deploy application blueprint.

## Puppet Service

Users have a choice of installing Puppet Community or Puppet Enterprise.

### Puppet Community

1. Create new service in the catalog.
2. Use the following values:

       * Name: Puppet
       * Version: 2.7
       * Tags: "Other"
       * Supported OSes: Any Operating System in RHEL and Debian OS family.
       * Supported Components: script.

3. Add script/puppet_community.sh to service install lifecycle.
4. Add the global_conf properties with the value: https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf (see global_conf.png)

## Puppet Modules

There's over 400+ modules at [Puppet Forge](http://forge.puppetlabs.com/) and they can be used to deploy a wide variety of applications. The example below describes the process of deploying mysql module, however any other module can be used. For complex modules check the forge website for usage examples and documentation.

* Search and install modules
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
        /Users/john/.puppet/modules
        └── puppetlabs-mysql (v0.4.0)
* Create a new service in the catalog.
* Use the puppet module name and version for the new service (see module documentation for OS support).

        * Name: MySQL
        * Version: 0.4.0
        ...

* List available puppet classes:
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
* Generate appdirector service script:
        /bin/appdir_module.rb mysql 
        #!/bin/bash
        
        . $global_conf
        
        export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        
        set -u
        set -e
        
        puppet module install puppetlabs/mysql
        
        cat > /tmp/mysql.pp <<EOF
        class { 'mysql':
         package_ensure => $package_ensure,
         package_name => $package_name,
        }
        EOF
        puppet apply --verbose /tmp/mysql.pp

* Add the global_conf properties with the value: https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf (see global_conf.png)
* Add puppet class parameters as properties with the default value of undef (do not quote).

      * package_ensure, string, default: undef
      * package_name, string, default: undef

* Create a new blueprint.
* Add Puppet service.
* Add MySQL service.
* Create dependency between MySQL and Puppet service.
* Deploy application.

## Examples

In the sections below, we will provide step by step instructions for deploying Jenkins, and a custom Puppet manifest.

### Deploying Jenkins

Deploying jenkins

* install rtyler/jenkins module from forge:
    $ puppet module install rtyler/jenkins
* generate appdirector service script:
    $ ./bin/appdir_module.rb jenkins
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
* create new service in the catalog:

### Custom Puppet Manifests

Once Puppet's service is created, AppDirector 

