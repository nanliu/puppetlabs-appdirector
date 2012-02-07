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

  # not dependable:
  $confdir    = inline_template("<%= Puppet[:confdir] %>")
  $modulepath = inline_template("<%= Puppet[:modulepath] %>")

  file { "${confdir}/hiera.yaml":
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0644',
    source => 'puppet:///modules/appdirector/hiera.yaml',
  }

  Exec {
    path => '/usr/local/bin:/usr/bin:/bin',
  }

  exec { 'vcsrepo':
    command => 'git clone git://github.com/puppetlabs/puppet-vcsrepo vcsrepo',
    cwd     => $modulepath,
    creates => "${modulepath}/vcsrepo",
  }

  exec { 'hiera-puppet':
    command => 'git clone git://github.com/puppetlabs/hiera-puppet',
    cwd     => $modulepath,
    creates => "${modulepath}/hiera-puppet",
  }

}
