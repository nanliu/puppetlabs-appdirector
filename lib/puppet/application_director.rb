require 'erb'

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
      modules.find{|x| x.name == module_name}
    end

    def list
      classes = Puppet::Face[:resource_type,:current].search('*') || []
      classes = classes.collect{ |x| x.name if x.type==:hostclass }.compact.sort
    end

    def generate(name)
      class_name  = name
      module_name = name.split('::').first
      forge_name  = forge(module_name).forge_name

      arguments = find(class_name).arguments.keys

      params = arguments.collect{|x| "  #{x} => $#{x}" }.join("\n")

      template = ERB.new <<-EOT
#!/bin/bash

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -u
set -e

puppet module install <%= forge_name %>

# Add any puppet class parameter to appdirector service properties with default value undef.
cat > /tmp/<%= class_name.gsub('::','_') %>.pp <<EOF
class { '<%= class_name %>':
<%= params %>
}
EOF

puppet apply --verbose --no-color /tmp/<%= class_name.gsub('::','_') %>.pp
      EOT
      puts template.result(binding)
    end
  end
end

