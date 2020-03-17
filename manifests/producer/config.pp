# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Resource: kafka::producer::config
#
# This private resource is meant to be called from `kafka::producer`.
# It manages the producer config files
#
define kafka::producer::config(
  String $producer_properties_name = $kafka::params::producer_properties_name,
  Stdlib::Absolutepath $config_dir = $kafka::producer::config_dir,
  String $service_name             = $kafka::producer::service_name,
  Boolean $service_install         = $kafka::producer::service_install,
  Boolean $service_restart         = $kafka::producer::service_restart,
  Hash $config                     = $kafka::producer::config,
  Stdlib::Filemode $config_mode    = $kafka::producer::config_mode,
  String $group                    = $kafka::producer::group,
) {

  if ($service_install and $service_restart) {
    $config_notify = Service[$service_name]
  } else {
    $config_notify = undef
  }

  $doctag = 'producerconfigs'
  file { "${config_dir}/${producer_properties_name}.properties":
    ensure  => present,
    owner   => 'root',
    group   => $group,
    mode    => $config_mode,
    content => template('kafka/properties.erb'),
    notify  => $config_notify,
    require => File[$config_dir],
  }
}
