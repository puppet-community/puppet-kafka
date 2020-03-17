# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Resource: kafka::mirror::install
#
# This private resource is meant to be called from `kafka::mirror`.
# It downloads the package and installs it.
#
define kafka::mirror::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if !defined(Class['::kafka']) {
    class { '::kafka':
      version        => $kafka::params::version,
      scala_version  => $kafka::params::scala_version,
      install_dir    => $kafka::params::install_dir,
      mirror_url     => $kafka::params::mirror_url,
      install_java   => $kafka::params::install_java,
      package_dir    => $kafka::params::package_dir,
      package_name   => $kafka::params::package_name,
      package_ensure => $kafka::params::package_ensure,
      user           => $kafka::params::user,
      group          => $kafka::params::group,
      user_id        => $kafka::params::user_id,
      group_id       => $kafka::params::group_id,
      manage_user    => $kafka::params::manage_user,
      manage_group   => $kafka::params::manage_group,
      config_dir     => $kafka::params::config_dir,
      log_dir        => $kafka::params::log_dir,
    }
  }
}
