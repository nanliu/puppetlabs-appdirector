# class: appdirector
#
#
class appdirector (
  $provider = 'gem',
  # not guaranteed to be reliable:
  $confdir  = inline_template("<%= Puppet[:confdir] %>"),
  $mod_path = inline_template("<%= Puppet[:modulepath].split(':').first %>")
) {

  package { 'hiera':
    ensure   => present,
    provider => $provider,
  }

  package { 'hiera-puppet':
    ensure   => present,
    provider => $provider,
  }

  file { "${confdir}/hiera.yaml":
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0644',
    source => 'puppet:///modules/appdirector/hiera.yaml',
    replace => false,
  }

  exec { 'hiera-puppet':
    command => 'git clone git://github.com/puppetlabs/hiera-puppet',
    cwd     => $mod_path,
    path    => '/usr/local/bin:/usr/bin:/bin',
    creates => "${mod_path}/hiera-puppet",
  }

}
