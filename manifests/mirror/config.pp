# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::mirror::config
#
# This private resource is meant to be called from `kafka::mirror`.
# It manages the mirror-maker config files
#
define kafka::mirror::config(
  Stdlib::Absolutepath $config_dir   = $kafka::params::config_dir,
  String $service_name               = $kafka::params::mirror_service_name,
  Boolean $service_install           = $kafka::params::service_install,
  Boolean $service_restart           = $kafka::params::service_restart,
  Hash $consumer_config              = $kafka::params::consumer_config,
  Hash $producer_config              = $kafka::params::producer_config,
  Stdlib::Filemode $config_mode      = $kafka::params::config_mode,
  String $group                      = $kafka::params::group,
  String $d_producer_properties_name = $kafka::params::producer_properties_name,
  String $d_consumer_properties_name = $kafka::params::consumer_properties_name,
) {
  $mirror_name = $title

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $consumer_config['group.id'] == '' {
    fail('[Consumer] You need to specify a value for group.id')
  }
  if $consumer_config['zookeeper.connect'] == '' {
    fail('[Consumer] You need to specify a value for zookeeper.connect')
  }
  if $producer_config['bootstrap.servers'] == '' {
    fail('[Producer] You need to specify a value for bootstrap.servers')
  }

  if $mirror_name != '' and $mirror_name != $kafka::params::mirror_default_name {
    $final_service_name       = "${service_name}-${mirror_name}"
    $consumer_properties_name = "${d_consumer_properties_name}-${mirror_name}"
    $producer_properties_name = "${d_producer_properties_name}-${mirror_name}"
  } else {
    $final_service_name       = $service_name
    $consumer_properties_name = $d_consumer_properties_name
    $producer_properties_name = $d_producer_properties_name
  }

  ::kafka::consumer::config { $title:
    consumer_properties_name => $consumer_properties_name,
    config_dir               => $config_dir,
    config_mode              => $config_mode,
    service_name             => $final_service_name,
    service_install          => $service_install,
    service_restart          => $service_restart,
    config                   => $consumer_config,
    group                    => $group,
  }

  ::kafka::producer::config { $title:
    producer_properties_name => $producer_properties_name,
    config_dir               => $config_dir,
    config_mode              => $config_mode,
    service_name             => $final_service_name,
    service_install          => $service_install,
    service_restart          => $service_restart,
    config                   => $producer_config,
    group                    => $group,
  }
}
