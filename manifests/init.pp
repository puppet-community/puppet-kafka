# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka
#
# This class will install kafka binaries
#
# === Requirements/Dependencies
#
# Currently requires the puppetlabs/stdlib module on the Puppet Forge in
# order to validate much of the the provided configuration.
#
# === Parameters
#
# [*version*]
# The version of kafka that should be installed.
#
# [*scala_version*]
# The scala version what kafka was built with.
#
# [*install_dir*]
# The directory to install kafka to.
#
# [*mirror_url*]
# The url where the kafka is downloaded from.
#
# [*install_java*]
# Install java if it's not already installed.
#
# [*package_dir*]
# The directory to install kafka.
#
# [*package_name*]
# Package name, when installing kafka from a package.
#
# [*package_ensure*]
# Package version (or 'present', 'absent', 'latest'), when installing kafka from a package.
#
# [*user*]
# User to run kafka as.
#
# [*group*]
# Group to run kafka as.
#
# [*user_id*]
# Create the kafka user with this ID.
#
# [*system_user*]
# Whether the kafka user is a system user or not.
#
# [*group_id*]
# Create the kafka group with this ID.
#
# [*system_group*]
# Whether the kafka group is a system group or not.
#
# [*manage_user*]
# Create the kafka user if it's not already present.
#
# [*manage_group*]
# Create the kafka group if it's not already present.
#
# [*config_dir*]
# The directory to create the kafka config files to.
#
# [*log_dir*]
# The directory for kafka log files.
#
# === Examples
#
#
class kafka (
  String $version                   = $kafka::params::version,
  String $scala_version             = $kafka::params::scala_version,
  Stdlib::Absolutepath $install_dir = $kafka::params::install_dir,
  Stdlib::HTTPUrl $mirror_url       = $kafka::params::mirror_url,
  Boolean $install_java             = $kafka::params::install_java,
  Stdlib::Absolutepath $package_dir = $kafka::params::package_dir,
  Optional[String] $package_name    = $kafka::params::package_name,
  Optional[String] $mirror_subpath  = $kafka::params::mirror_subpath,
  Optional[String] $proxy_server    = $kafka::params::proxy_server,
  Optional[String] $proxy_port      = $kafka::params::proxy_port,
  Optional[String] $proxy_host      = $kafka::params::proxy_host,
  Optional[String] $proxy_type      = $kafka::params::proxy_type,
  String $package_ensure            = $kafka::params::package_ensure,
  String $user                      = $kafka::params::user,
  String $group                     = $kafka::params::group,
  Boolean $system_user              = $kafka::params::system_user,
  Boolean $system_group             = $kafka::params::system_group,
  Optional[Integer] $user_id        = $kafka::params::user_id,
  Optional[Integer] $group_id       = $kafka::params::group_id,
  Boolean $manage_user              = $kafka::params::manage_user,
  Boolean $manage_group             = $kafka::params::manage_group,
  String  $kafka_dir                = $kafka::params::kafka_dir,
  String  $kafka_log_dir            = $kafka::params::kafka_log_dir,
  String  $zookeeper_hosts          = $kafka::params::zookeeper_hosts,
  Stdlib::Absolutepath $config_dir  = $kafka::params::config_dir,
  Stdlib::Absolutepath $log_dir     = $kafka::params::log_dir,
  Optional[String] $install_mode    = $kafka::params::install_mode,
) inherits kafka::params {

  if $install_java {
    class { '::java':
      distribution => 'jdk',
    }
  }

  if $manage_group {
    group { $group:
      ensure => present,
      gid    => $group_id,
      system => $system_group,
    }
  }

  if $manage_user {
    user { $user:
      ensure  => present,
      shell   => '/bin/bash',
      require => Group[$group],
      uid     => $user_id,
      system  => $system_user,
    }
  }

  file { $config_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }

  file { $log_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => [
      Group[$group],
      User[$user],
    ],
  }

  file { "${kafka_dir}/compareTopicConfig.sh":
    mode   => '0755',
    owner  => $user ,
    group  => $group ,
    content => template('kafka/compareTopicConfig.sh.erb'),
  } ->
  exec { "create config topic result file":
    path    => "/usr/bin:/usr/sbin/:/bin:/sbin:${bin_dir}",
    command => "kafka-topics.sh --zookeeper ${zookeeper_hosts} --topics-with-overrides --describe > ${kafka_log_dir}/resultsTopicsConfig.txt ",
    unless  => "${kafka_dir}/compareTopicConfig.sh",
  }


  if $package_name == undef {

    include ::archive

    $mirror_path = $mirror_subpath ? {
      # if mirror_subpath was not changed,
      # we adapt it for the version
      $kafka::params::mirror_subpath => "kafka/${version}",
      # else, we just take whatever was supplied:
      default                        => $mirror_subpath,
    }

    $basefilename = "kafka_${scala_version}-${version}.tgz"
    $package_url = "${mirror_url}${mirror_path}/${basefilename}"

    $source = $mirror_url ?{
      /tgz$/ => $mirror_url,
      default  => $package_url,
    }

    $install_directory = $install_dir ? {
      # if install_dir was not changed,
      # we adapt it for the scala_version and the version
      $kafka::params::install_dir => "/opt/kafka-${scala_version}-${version}",
      # else, we just take whatever was supplied:
      default                     => $install_dir,
    }

    file { $package_dir:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      require => [
        Group[$group],
        User[$user],
      ],
    }

    file { $install_directory:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => $install_mode,
      require => [
        Group[$group],
        User[$user],
      ],
    }

    file { '/opt/kafka':
      ensure  => link,
      target  => $install_directory,
      require => File[$install_directory],
    }

    if $proxy_server == undef and $proxy_host != undef and $proxy_port != undef {
      $final_proxy_server = "${proxy_host}:${proxy_port}"
    } else {
      $final_proxy_server = $proxy_server
    }

    archive { "${package_dir}/${basefilename}":
      ensure          => present,
      extract         => true,
      extract_command => 'tar xfz %s --strip-components=1',
      extract_path    => $install_directory,
      source          => $source,
      creates         => "${install_directory}/config",
      cleanup         => true,
      proxy_server    => $final_proxy_server,
      proxy_type      => $proxy_type,
      user            => $user,
      group           => $group,
      require         => [
        File[$package_dir],
        File[$install_directory],
        Group[$group],
        User[$user],
      ],
      before          => File[$config_dir],
    }

  } else {

    package { $package_name:
      ensure => $package_ensure,
      before => File[$config_dir],
    }

  }
}
