# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::consumer::config
#
# This private class is meant to be called from `kafka::consumer`.
# It manages the consumer config files
#
class kafka::consumer::config(
  Stdlib::Absolutepath $config_dir = $kafka::consumer::config_dir,
  String $service_name             = $kafka::consumer::service_name,
  Boolean $service_install         = $kafka::consumer::service_install,
  Boolean $service_restart         = $kafka::consumer::service_restart,
  Hash $config                     = $kafka::consumer::config,
  Stdlib::Filemode $config_mode    = $kafka::consumer::config_mode,
  String $user_name                = $kafka::consumer::user_name,
  String $group                    = $kafka::consumer::group,
) {

  if ($service_install and $service_restart) {
    $config_notify = Service[$service_name]
  } else {
    $config_notify = undef
  }

  $doctag = 'consumerconfigs'
  file { "${config_dir}/consumer.properties":
    ensure  => present,
    owner   => $user_name,
    group   => $group,
    mode    => $config_mode,
    content => template('kafka/properties.erb'),
    notify  => $config_notify,
    require => File[$config_dir],
  }
}
