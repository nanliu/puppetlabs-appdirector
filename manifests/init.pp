# class: appdirector
#
#
class appdirector (
  $provider = 'gem'
) {

  package { 'hiera':
    ensure   => present,
    provider => $provider,
  }

  package { 'hiera-puppet':
    ensure   => present,
    provider => $provider,
  }

  $puppet_confdir = inline_template("<%= Puppet[:confdir] %>")

  file { '${puppet_confdir}/hiera.yaml':
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0644',
    source => 'puppet:///modules/appdirector/hiera.yaml',
  }

}
