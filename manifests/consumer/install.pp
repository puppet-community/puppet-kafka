# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::consumer::install
#
# This private class is meant to be called from `kafka::consumer`.
# It downloads the package and installs it.
#
class kafka::consumer::install {

  assert_private()

  if !defined(Class['kafka']) {
    class { 'kafka':
      manage_java    => $kafka::consumer::manage_java,
      manage_group   => $kafka::consumer::manage_group,
      group_id       => $kafka::consumer::group_id,
      group_name     => $kafka::consumer::group_name,
      manage_user    => $kafka::consumer::manage_user,
      user_id        => $kafka::consumer::user_id,
      user_name      => $kafka::consumer::user_name,
      config_dir     => $kafka::consumer::config_dir,
      log_dir        => $kafka::consumer::log_dir,
      mirror_url     => $kafka::consumer::mirror_url,
      kafka_version  => $kafka::consumer::kafka_version,
      scala_version  => $kafka::consumer::scala_version,
      install_dir    => $kafka::consumer::install_dir,
      package_dir    => $kafka::consumer::package_dir,
      package_ensure => $kafka::consumer::package_ensure,
      package_name   => $kafka::consumer::package_name,
    }
  }
}
