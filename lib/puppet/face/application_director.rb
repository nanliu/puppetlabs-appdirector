require 'puppet/face'
require 'puppet/application_director'

Puppet::Face.define(:application_director, '0.0.1') do
  copyright 'Puppet Labs', 2012
  license   'Apache 2 license; see COPYING'
  summary   'Export Puppet modules for VMware vFabric Application Director.'
  description <<-'EOT'
    ...
  EOT
end
