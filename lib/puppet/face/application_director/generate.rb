require 'puppet/face/application_director'

Puppet::Face.define :application_director, '0.0.1' do
  action :generate do
    summary 'Generate Application Director script for puppet class.'
    description <<-EOT
      Generate vFabric Application Director script for puppet class.
    EOT

    arguments "<name>"

    option "--modulepath MODULEPATH" do
      default_to { Puppet[:modulepath] }
      summary "Puppet module path."
      description <<-EOT
        Puppet module path.
      EOT
    end

    when_invoked do |name, options|
      Puppet[:modulepath] = options[:modulepath] if options[:modulepath]
      Puppet::ApplicationDirector.new(options[:modulepath]).generate(name)
    end

    when_rendering :console do |values|
      values
    end
  end
end
