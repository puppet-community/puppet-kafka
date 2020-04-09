# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::mirror::config
#
# This private class is meant to be called from `kafka::mirror`.
# It manages the mirror-maker config files
#
class kafka::mirror::config(
  Boolean $manage_service          = $kafka::mirror::manage_service,
  String $service_name             = $kafka::mirror::service_name,
  Boolean $service_restart         = $kafka::mirror::service_restart,
  Hash $consumer_config            = $kafka::mirror::consumer_config,
  Hash $producer_config            = $kafka::mirror::producer_config,
  Stdlib::Absolutepath $config_dir = $kafka::mirror::config_dir,
  String $user_name                = $kafka::mirror::user_name,
  String $group_name               = $kafka::mirror::group_name,
  Stdlib::Filemode $config_mode    = $kafka::mirror::config_mode,
) {

  assert_private()

  if $consumer_config['group.id'] == '' {
    fail('[Consumer] You need to specify a value for group.id')
  }
  if $consumer_config['zookeeper.connect'] == '' {
    fail('[Consumer] You need to specify a value for zookeeper.connect')
  }
  if $producer_config['bootstrap.servers'] == '' {
    fail('[Producer] You need to specify a value for bootstrap.servers')
  }

  class { 'kafka::consumer::config':
    manage_service  => $manage_service,
    service_name    => $service_name,
    service_restart => $service_restart,
    config          => $consumer_config,
    config_dir      => $config_dir,
    user_name       => $user_name,
    group_name      => $group_name,
    config_mode     => $config_mode,
  }

  class { 'kafka::producer::config':
    manage_service  => $manage_service,
    service_name    => $service_name,
    service_restart => $service_restart,
    config          => $producer_config,
    config_dir      => $config_dir,
    user_name       => $user_name,
    group_name      => $group_name,
    config_mode     => $config_mode,
  }
}
