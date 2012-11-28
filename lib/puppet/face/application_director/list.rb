require 'puppet/face/application_director'

Puppet::Face.define :application_director, '0.0.1' do
  action :list do
    summary 'List Puppet classes available for export.'
    description <<-EOT
      Obtains a list of puppet classes available for export.
    EOT

    option "--modulepath MODULEPATH" do
      default_to { Puppet[:modulepath] }
      summary "Puppet module path."
      description <<-EOT
        Puppet module path.
      EOT
    end

    default
    when_invoked do |options|
      Puppet[:modulepath] = options[:modulepath] if options[:modulepath]
      Puppet::ApplicationDirector.new(options[:modulepath]).list
    end

    when_rendering :console do |values|
      if values.empty?
        "No modules discovered. Additional modules available via 'puppet module' command."
      else
        values = values.collect do |v|
          v = (v.include? '::') ? '  '+v : v
        end
        values = ["Puppet classes:"] + values
        values.join("\n").to_s
      end
    end
  end
end
