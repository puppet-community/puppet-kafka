# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::broker
#
# This class will install kafka with the broker role.
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
# [*group_id*]
# Create the kafka group with this ID.
#
# [*manage_user*]
# Create the kafka user if it's not already present.
#
# [*manage_group*]
# Create the kafka group if it's not already present.
#
# [*config_mode*]
# The permissions for the config files.
#
# [*config_dir*]
# The directory to create the kafka config files to.
#
# [*log_dir*]
# The directory for kafka log files.
#
# [*bin_dir*]
# The directory where the kafka scripts are.
#
# [*service_name*]
# Set the name of the service.
#
# [*service_install*]
# Install the init.d or systemd service.
#
# [*service_ensure*]
# Set the ensure state of the service to 'stopped' or 'running'.
#
# [*service_restart*]
# Whether the configuration files should trigger a service restart.
#
# [*service_requires*]
# Set the list of services required to be running before Kafka.
#
# [*limit_nofile*]
# Set the 'LimitNOFILE' option of the systemd service.
#
# [*limit_core*]
# Set the 'LimitCORE' option of the systemd service.
#
# [*timeout_stop*]
# Set the 'TimeoutStopSec' option of the systemd service.
#
# [*exec_stop*]
# Set the 'ExecStop' option of the systemd service to 'kafka-server-stop.sh'.
#
# [*daemon_start*]
# Use the '-daemon' option when starting Kafka with 'kafka-server-start.sh'.
#
# [*env*]
# A hash of the environment variables to set.
#
# [*config*]
# A hash of the configuration options.
#
# === Examples
#
# Create a single broker instance which talks to a local zookeeper instance.
#
# class { 'kafka::broker':
#  config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' }
# }
#
class kafka::broker (
  String $version                            = $kafka::params::version,
  String $scala_version                      = $kafka::params::scala_version,
  Stdlib::Absolutepath $install_dir          = $kafka::params::install_dir,
  Stdlib::HTTPUrl $mirror_url                = $kafka::params::mirror_url,
  Boolean $install_java                      = $kafka::params::install_java,
  Stdlib::Absolutepath $package_dir          = $kafka::params::package_dir,
  Optional[String] $package_name             = $kafka::params::package_name,
  String $package_ensure                     = $kafka::params::package_ensure,
  String $user                               = $kafka::params::user,
  String $group                              = $kafka::params::group,
  Optional[Integer] $user_id                 = $kafka::params::user_id,
  Optional[Integer] $group_id                = $kafka::params::group_id,
  Boolean $manage_user                       = $kafka::params::manage_user,
  Boolean $manage_group                      = $kafka::params::manage_group,
  Stdlib::Filemode $config_mode              = $kafka::params::config_mode,
  Stdlib::Absolutepath $config_dir           = $kafka::params::config_dir,
  Stdlib::Absolutepath $log_dir              = $kafka::params::log_dir,
  Stdlib::Absolutepath $bin_dir              = $kafka::params::bin_dir,
  String $service_name                       = 'kafka',
  Boolean $service_install                   = $kafka::params::service_install,
  Enum['running', 'stopped'] $service_ensure = $kafka::params::service_ensure,
  Boolean $service_restart                   = $kafka::params::service_restart,
  Array[String] $service_requires            = $kafka::params::service_requires,
  Optional[String] $limit_nofile             = $kafka::params::limit_nofile,
  Optional[String] $limit_core               = $kafka::params::limit_core,
  Optional[String] $timeout_stop             = $kafka::params::timeout_stop,
  Boolean $exec_stop                         = $kafka::params::exec_stop,
  Boolean $daemon_start                      = $kafka::params::daemon_start,
  Hash $env                                  = {},
  Hash $config                               = {},
  String $heap_opts                          = $kafka::params::broker_heap_opts,
  String $jmx_opts                           = $kafka::params::broker_jmx_opts,
  String $log4j_opts                         = $kafka::params::broker_log4j_opts,
  String $systemd_files_path                 = $kafka::params::systemd_files_path,
  $opts                                      = $kafka::params::broker_opts,
) inherits kafka::params {

  class { '::kafka::broker::install': }
  -> class { '::kafka::broker::config': }
  -> class { '::kafka::broker::service': }
  -> Class['kafka::broker']
}
