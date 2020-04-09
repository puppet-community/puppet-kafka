# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::producer::config
#
# This private class is meant to be called from `kafka::producer`.
# It manages the producer config files
#
class kafka::producer::config(
  Boolean $manage_service          = $kafka::producer::manage_service,
  String $service_name             = $kafka::producer::service_name,
  Boolean $service_restart         = $kafka::producer::service_restart,
  Hash $config                     = $kafka::producer::config,
  Stdlib::Absolutepath $config_dir = $kafka::producer::config_dir,
  String $user_name                = $kafka::producer::user_name,
  String $group_name               = $kafka::producer::group_name,
  Stdlib::Filemode $config_mode    = $kafka::producer::config_mode,
) {

  if ($manage_service and $service_restart) {
    $config_notify = Service[$service_name]
  } else {
    $config_notify = undef
  }

  $doctag = 'producerconfigs'
  file { "${config_dir}/producer.properties":
    ensure  => present,
    owner   => $user_name,
    group   => $group_name,
    mode    => $config_mode,
    content => template('kafka/properties.erb'),
    notify  => $config_notify,
    require => File[$config_dir],
  }
}
