# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Resource: kafka::consumer::install
#
# This private resource is meant to be called from `kafka::consumer`.
# It downloads the package and installs it.
#
define kafka::consumer::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if !defined(Class['::kafka']) {
    class { '::kafka':
      version        => $kafka::consumer::version,
      scala_version  => $kafka::consumer::scala_version,
      install_dir    => $kafka::consumer::install_dir,
      mirror_url     => $kafka::consumer::mirror_url,
      install_java   => $kafka::consumer::install_java,
      package_dir    => $kafka::consumer::package_dir,
      package_name   => $kafka::consumer::package_name,
      package_ensure => $kafka::consumer::package_ensure,
      user           => $kafka::consumer::user,
      group          => $kafka::consumer::group,
      user_id        => $kafka::consumer::user_id,
      group_id       => $kafka::consumer::group_id,
      manage_user    => $kafka::consumer::manage_user,
      manage_group   => $kafka::consumer::manage_group,
      config_dir     => $kafka::consumer::config_dir,
      log_dir        => $kafka::consumer::log_dir,
    }
  }
}
