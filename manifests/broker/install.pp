# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::broker::install
#
# This private class is meant to be called from `kafka::broker`.
# It downloads the package and installs it.
#
class kafka::broker::install {

  assert_private()

  if !defined(Class['kafka']) {
    class { 'kafka':
      manage_java    => $kafka::broker::manage_java,
      manage_group   => $kafka::broker::manage_group,
      group_id       => $kafka::broker::group_id,
      group_name     => $kafka::broker::group_name,
      manage_user    => $kafka::broker::manage_user,
      user_id        => $kafka::broker::user_id,
      user_name      => $kafka::broker::user_name,
      config_dir     => $kafka::broker::config_dir,
      log_dir        => $kafka::broker::log_dir,
      mirror_url     => $kafka::broker::mirror_url,
      kafka_version  => $kafka::broker::kafka_version,
      scala_version  => $kafka::broker::scala_version,
      install_dir    => $kafka::broker::install_dir,
      package_dir    => $kafka::broker::package_dir,
      package_ensure => $kafka::broker::package_ensure,
      package_name   => $kafka::broker::package_name,
    }
  }
}
