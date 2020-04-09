# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::producer::service
#
# This private class is meant to be called from `kafka::producer`.
# It manages the kafka-producer service
#
class kafka::producer::service(
  Boolean $manage_service                    = $kafka::producer::manage_service,
  Enum['running', 'stopped'] $service_ensure = $kafka::producer::service_ensure,
  String $service_name                       = $kafka::producer::service_name,
  String $user_name                          = $kafka::producer::user_name,
  String $group_name                         = $kafka::producer::group_name,
  Stdlib::Absolutepath $config_dir           = $kafka::producer::config_dir,
  Stdlib::Absolutepath $log_dir              = $kafka::producer::log_dir,
  Stdlib::Absolutepath $bin_dir              = $kafka::producer::bin_dir,
  Array[String] $service_requires            = $kafka::producer::service_requires,
  Optional[String] $limit_nofile             = $kafka::producer::limit_nofile,
  Optional[String] $limit_core               = $kafka::producer::limit_core,
  Hash $env                                  = $kafka::producer::env,
  $input                                     = $kafka::producer::input,
  String $jmx_opts                           = $kafka::producer::jmx_opts,
  String $log4j_opts                         = $kafka::producer::log4j_opts,
  Hash $service_config                       = $kafka::producer::service_config,
) {

  assert_private()

  if $manage_service {

    if $service_config['broker-list'] == '' {
      fail('[Producer] You need to specify a value for broker-list')
    }
    if $service_config['topic'] == '' {
      fail('[Producer] You need to specify a value for topic')
    }

    $env_defaults = {
      'KAFKA_JMX_OPTS'   => $jmx_opts,
      'KAFKA_LOG4J_OPTS' => $log4j_opts,
    }
    $environment = deep_merge($env_defaults, $env)

    if $facts['service_provider'] == 'systemd' {
      fail('Console Producer is not supported on systemd, because the stdin of the process cannot be redirected')
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
