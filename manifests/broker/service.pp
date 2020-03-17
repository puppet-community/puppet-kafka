# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::broker::service
#
# This private class is meant to be called from `kafka::broker`.
# It manages the kafka service
#
class kafka::broker::service(
  String $user                               = $kafka::broker::user,
  String $group                              = $kafka::broker::group,
  Stdlib::Absolutepath $config_dir           = $kafka::broker::config_dir,
  Stdlib::Absolutepath $log_dir              = $kafka::broker::log_dir,
  Stdlib::Absolutepath $bin_dir              = $kafka::broker::bin_dir,
  String $service_name                       = $kafka::broker::service_name,
  Boolean $service_install                   = $kafka::broker::service_install,
  Enum['running', 'stopped'] $service_ensure = $kafka::broker::service_ensure,
  Array[String] $service_requires            = $kafka::broker::service_requires,
  Optional[String] $limit_nofile             = $kafka::broker::limit_nofile,
  Optional[String] $limit_core               = $kafka::broker::limit_core,
  Optional[String] $timeout_stop             = $kafka::broker::timeout_stop,
  Boolean $exec_stop                         = $kafka::broker::exec_stop,
  Boolean $daemon_start                      = $kafka::broker::daemon_start,
  Hash $env                                  = $kafka::broker::env,
  String $heap_opts                          = $kafka::broker::heap_opts,
  String $jmx_opts                           = $kafka::broker::jmx_opts,
  String $log4j_opts                         = $kafka::broker::log4j_opts,
  $opts                                      = $kafka::broker::opts,
  String $producer_properties_name           = $kafka::params::producer_properties_name,
  String $consumer_properties_name           = $kafka::params::consumer_properties_name,
  String $systemd_files_path                 = $kafka::params::systemd_files_path,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $service_install {
    $env_defaults = {
      'KAFKA_HEAP_OPTS'  => $heap_opts,
      'KAFKA_JMX_OPTS'   => $jmx_opts,
      'KAFKA_LOG4J_OPTS' => $log4j_opts,
      'KAFKA_OPTS'       => $opts,
      'LOG_DIR'          => $log_dir,
    }
    $environment = deep_merge($env_defaults, $env)

    if $::service_provider == 'systemd' {
      include ::systemd

      if $systemd_files_path != $kafka::params::systemd_files_path {
        file { "${kafka::params::systemd_files_path}/${service_name}.service":
          ensure  => absent,
        }
      }

      file { "${systemd_files_path}/${service_name}.service":
        ensure  => file,
        mode    => '0644',
        content => template('kafka/unit.erb'),
      }

      file { "/etc/init.d/${service_name}":
        ensure => absent,
      }

      File["${systemd_files_path}/${service_name}.service"]
      ~> Exec['systemctl-daemon-reload']
      -> Service[$service_name]

    } else {
      file { "/etc/init.d/${service_name}":
        ensure  => file,
        mode    => '0755',
        content => template('kafka/init.erb'),
        before  => Service[$service_name],
      }
    }

    service { $service_name:
      ensure     => $service_ensure,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
