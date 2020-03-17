# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Resource: kafka::consumer::service
#
# This private resource is meant to be called from `kafka::consumer`.
# It manages the kafka-consumer service
#
define kafka::consumer::service(
  String $user                               = $kafka::consumer::user,
  String $group                              = $kafka::consumer::group,
  Stdlib::Absolutepath $config_dir           = $kafka::consumer::config_dir,
  Stdlib::Absolutepath $log_dir              = $kafka::consumer::log_dir,
  Stdlib::Absolutepath $bin_dir              = $kafka::consumer::bin_dir,
  String $service_name                       = $kafka::consumer::service_name,
  Boolean $service_install                   = $kafka::consumer::service_install,
  Enum['running', 'stopped'] $service_ensure = $kafka::consumer::service_ensure,
  Array[String] $service_requires            = $kafka::consumer::service_requires,
  Optional[String] $limit_nofile             = $kafka::consumer::limit_nofile,
  Optional[String] $limit_core               = $kafka::consumer::limit_core,
  Hash $env                                  = $kafka::consumer::env,
  String $jmx_opts                           = $kafka::consumer::jmx_opts,
  String $log4j_opts                         = $kafka::consumer::log4j_opts,
  Hash $service_config                       = $kafka::consumer::service_config,
  String $producer_properties_name           = $kafka::params::producer_properties_name,
  String $consumer_properties_name           = $kafka::params::consumer_properties_name,
  String $systemd_files_path                 = $kafka::params::systemd_files_path,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $service_install {

    if $service_config['topic'] == '' {
      fail('[Consumer] You need to specify a value for topic')
    }
    if $service_config['zookeeper'] == '' {
      fail('[Consumer] You need to specify a value for zookeeper')
    }

    $env_defaults = {
      'KAFKA_JMX_OPTS'   => $jmx_opts,
      'KAFKA_LOG4J_OPTS' => $log4j_opts,
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
