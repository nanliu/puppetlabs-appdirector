require 'date'
require 'erb'
require 'gyoku'

module Puppet
  class ApplicationDirector
    attr_reader :module_path

    def initialize(mpath=Puppet[:modulepath])
      @module_path = mpath
    end

    def find(name, type=:hostclass)
      Puppet::Face[:resource_type, :current].search('*').find{ |x| x.type==type and x.name == name }
    end

    def forge(module_name)
      modules = Puppet::Face[:module,:current].list.values.flatten
      result = modules.find{|x| x.name == module_name}
      raise "module '#{module_name}' not available in module path.\nExecute 'puppet application_director list' for available classes." unless result
      result
    end

    def list
      classes = Puppet::Face[:resource_type,:current].search('*') || []
      classes = classes.collect{ |x| x.name if x.type==:hostclass }.compact.sort
    end

    def generate(name)
      class_name = name
      module_name = name.split('::').first
      forge_module = forge(module_name)
      forge_name = forge_module.forge_name

      arguments = find(class_name).arguments.keys
      params = arguments.collect{|x| "  #{x} => $#{x}," }.join("\n")

      template = ERB.new <<-EOT
#!/bin/bash

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -u
set -e

puppet module install <%= forge_name %>

FILENAME=/tmp/<%= class_name.gsub('::','_') %>.$$.pp
# puppet class parameter in vFabric Application Director service properties
# should have default value undef.
cat > $FILENAME <<EOF
class { '<%= class_name %>':
<%= params %>
}
EOF

puppet apply --verbose --no-color $FILENAME
      EOT
      template.result(binding)
    end

    def os_versions()
      # TODO
    end

    def prop(key, value='undef', description='', secured=false, type='String')
      time = DateTime.now.to_s
      value = {
        'id' => 0,
          'inactive' => false,
          'lock-version' => 0,
          'last-updated' => time,
          'last-update-user' => 'SYSTEM',
          'created' => time,
          'create-user' => 'SYSTEM',
          'description' => description,
          'key' => key,
          'prop-type' => {
            'id' => 0,
            'inactive' => false,
            'lock-version' => 0,
            'last-updated' => time,
            'last-update-user' => 'SYSTEM',
            'created' => time,
            'create-user' => 'SYSTEM',
            'name' => type,
            'description' => 'Content (java.lang.String).',
          },
          'required' => true,
          'secured' => secured,
          'prop-auto-bind-type' => {
            'id' => 0,
            'inactive' => false,
            'lock-version' => 0,
            'last-updated' => time,
            'last-update-user' => 'SYSTEM',
            'created' => time,
            'create-user' => 'SYSTEM',
            'name' => 'None',
            'description' => 'Property will not participate in auto-binding.',
            'prop-auto-bind-type-enum' => 'NONE',
          },
          'value' => '<![CDATA['+value+']]>',
          'readonly' => false,
          'overridable' => true,
          'expression' => false,
          'ns2:bound-prop' => {
            'id' => 0,
            'inactive' => false,
            'lock-version' => 0,
            'last-updated' => time,
            'last-update-user' => 'SYSTEM',
            'created' => time,
            'create-user' => 'SYSTEM',
            'bind-lifecycle-type' => {
              'id' => 0,
              'inactive' => false,
              'lock-version' => 0,
              'last-updated' => time,
              'last-update-user' => 'SYSTEM',
              'created' => time,
              'create-user' => 'SYSTEM',
              'name' => 'Catalog',
              'description' => 'Bindable at service/catalog level.',
              'lifecycle-order' => 1,
            },
            'value' => '<![CDATA['+value+']]>',
            'overridable' => true,
            'expression' => false,
          },
        }
    end

    def export(name)
      time = DateTime.now.to_s
      class_name = name
      module_name = name.split('::').first
      forge_module = forge(module_name)

      # Not all forge modules follow semver:
      begin
        major, minor, micro = forge_module.version.split('.')
      rescue
        major, minor, micro = [0, 0, 0]
      end

      properties = []
      properties << prop('global_conf', 'https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf', 'URL to download Darwin global configuration for each node', false, 'Content')

      arguments = find(class_name).arguments.keys
      arguments.each do |k|
        properties << prop(k, 'undef')
      end

      service_versions = {
        'id' => 0,
        'inactive' => false,
        'lock-version' => 0,
        'last-updated' => time,
        'last-update-user' => 'SYSTEM',
        'created' => time,
        'name' => name,
        'description' => 'Puppet', # TODO: replace with forge details.
        'revision' => 0,
        'major' => major,
        'minor' => minor,
        'micro' => micro,
        'qualifier' => '',
        'dynamically-installable' => true,
        'auto-bind-properties' => false,
        'props' => properties,
        :order! => [ 'id', 'inactive', 'lock-version', 'last-updated', 'last-update-user', 'created', 'name', 'description', 'revision', 'major', 'minor', 'micro', 'qualifier', 'dynamically-installable', 'auto-bind-properties', 'props' ],
      }

      export_package = {
        'errors' => false,
        'application-director-version' => 'vFabric Application Director CLI BUILD [5.0.0-861241]',
        'service-versions' => service_versions,
        :order! => ['errors', 'application-director-version', 'service-versions']
      }

      data = {
        'ns26:export-package'=> export_package,
        :attributes! => {
          'ns26:export-package' => {
            'xmlns:ns2'  => 'http://www.vmware.com/darwin/schema/beans/props',
            'xmlns:ns3'  => 'http://www.vmware.com/darwin/schema/beans/metatag',
            'xmlns:ns4'  => 'http://www.vmware.com/darwin/schema/beans/entity',
            'xmlns:ns5'  => 'http://www.vmware.com/darwin/schema/beans/catalog/component',
            'xmlns:ns6'  => 'http://www.vmware.com/darwin/schema/beans/security',
            'xmlns:ns7'  => 'http://www.vmware.com/darwin/schema/beans/application',
            'xmlns:ns8'  => 'http://www.vmware.com/darwin/schema/beans/cloud/provider',
            'xmlns:ns9'  => 'http://www.vmware.com/darwin/schema/beans/blueprint',
            'xmlns:ns10' => 'http://www.vmware.com/darwin/schema/beans/physical/template',
            'xmlns:ns11' => 'http://www.vmware.com/darwin/schema/beans/cloud/tunnel',
            'xmlns:ns12' => 'http://www.vmware.com/darwin/schema/beans/deployment/environment',
            'xmlns:ns13' => 'http://www.vmware.com/darwin/schema/beans/driver/location',
            'xmlns:ns14' => 'http://www.vmware.com/darwin/schema/beans/scripts',
            'xmlns:ns15' => 'http://www.vmware.com/darwin/schema/beans/flow',
            'xmlns:ns16' => 'http://www.vmware.com/darwin/schema/beans/deployment/profile',
            'xmlns:ns17' => 'http://www.vmware.com/darwin/schema/beans/update/profile',
            'xmlns:ns18' => 'http://www.vmware.com/darwin/schema/beans/deployment',
            'xmlns:ns19' => 'http://www.vmware.com/darwin/schema/beans/security/ldap',
            'xmlns:ns20' => 'http://www.vmware.com/darwin/schema/beans/security/user',
            'xmlns:ns21' => 'http://www.vmware.com/darwin/schema/beans/networking',
            'xmlns:ns22' => 'http://www.vmware.com/darwin/schema/beans/ssl',
            'xmlns:ns23' => 'http://www.vmware.com/darwin/schema/beans/response',
            'xmlns:ns24' => 'http://www.vmware.com/darwin/schema/beans/notification',
            'xmlns:ns25' => 'http://www.vmware.com/darwin/schema/beans/api',
            'xmlns:ns26' => 'http://www.vmware.com/darwin/schema/beans/exim',
            'xmlns:ns27' => 'http://www.vmware.com/darwin/schema/beans/license',
          },
        }
      }
      xml = Gyoku.xml(data)
      "<?xml version='1.0' encoding='UTF-8'?>\n#{xml}"
    end
  end
end

