# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Resource: kafka::mirror::service
#
# This private resource is meant to be called from `kafka::mirror`.
# It manages the kafka-mirror service
#
define kafka::mirror::service(
  String $user                               = $kafka::params::user,
  String $group                              = $kafka::params::group,
  Stdlib::Absolutepath $config_dir           = $kafka::params::config_dir,
  Stdlib::Absolutepath $log_dir              = $kafka::params::log_dir,
  Stdlib::Absolutepath $bin_dir              = $kafka::params::bin_dir,
  String $service_name                       = $kafka::params::mirror_service_name,
  Boolean $service_install                   = $kafka::params::service_install,
  Enum['running', 'stopped'] $service_ensure = $kafka::params::service_ensure,
  Array[String] $service_requires            = $kafka::params::service_requires,
  Optional[String] $limit_nofile             = $kafka::params::limit_nofile,
  Optional[String] $limit_core               = $kafka::params::limit_core,
  Hash $env                                  = $kafka::params::env,
  Hash $consumer_config                      = $kafka::params::consumer_config,
  Hash $producer_config                      = $kafka::params::producer_config,
  Hash $service_config                       = $kafka::params::service_config,
  String $heap_opts                          = $kafka::params::mirror_heap_opts,
  String $jmx_opts                           = $kafka::params::mirror_jmx_opts,
  String $log4j_opts                         = $kafka::params::mirror_log4j_opts,
  String $d_producer_properties_name         = $kafka::params::producer_properties_name,
  String $d_consumer_properties_name         = $kafka::params::consumer_properties_name,
  String $systemd_files_path                 = $kafka::params::systemd_files_path,
) {
  $mirror_name = $title

  if $mirror_name != '' and $mirror_name != $kafka::params::mirror_default_name {
    $final_service_name       = "${service_name}-${mirror_name}"
    $producer_properties_name = "${d_producer_properties_name}-${mirror_name}"
    $consumer_properties_name = "${d_consumer_properties_name}-${mirror_name}"
  } else {
    $final_service_name       = $service_name
    $producer_properties_name = $d_producer_properties_name
    $consumer_properties_name = $d_consumer_properties_name
  }

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $service_install {
    $env_defaults = {
      'KAFKA_HEAP_OPTS'  => $heap_opts,
      'KAFKA_JMX_OPTS'   => $jmx_opts,
      'KAFKA_LOG4J_OPTS' => $log4j_opts,
    }
    $environment = deep_merge($env_defaults, $env)

    if $::service_provider == 'systemd' {
      include ::systemd

      if $systemd_files_path != $kafka::params::systemd_files_path {
        file { "${kafka::params::systemd_files_path}/${final_service_name}.service":
          ensure  => absent,
        }
      }

      file { "${systemd_files_path}/${final_service_name}.service":
        ensure  => file,
        mode    => '0644',
        content => template('kafka/unit.erb'),
        notify  => Service[$final_service_name],
      }

      file { "/etc/init.d/${final_service_name}":
        ensure => absent,
      }

      File["${systemd_files_path}/${final_service_name}.service"]
      ~> Exec['systemctl-daemon-reload']
      -> Service[$final_service_name]

    } else {
      file { "/etc/init.d/${final_service_name}":
        ensure  => file,
        mode    => '0755',
        content => template('kafka/init.erb'),
      }
    }

    service { $final_service_name:
      ensure     => $service_ensure,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
