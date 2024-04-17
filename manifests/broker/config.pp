# @summary
#   This class handles the Kafka (broker) config.
#
# @api private
#
class kafka::broker::config (
  Boolean $manage_service                       = $kafka::broker::manage_service,
  String[1] $service_name                       = $kafka::broker::service_name,
  Boolean $service_restart                      = $kafka::broker::service_restart,
  Hash[String[1], Any] $config                  = $kafka::broker::config,
  Stdlib::Absolutepath $config_dir              = $kafka::broker::config_dir,
  String[1] $user_name                          = $kafka::broker::user_name,
  String[1] $group_name                         = $kafka::broker::group_name,
  Stdlib::Filemode $config_mode                 = $kafka::broker::config_mode,
  Boolean $manage_log4j                         = $kafka::broker::manage_log4j,
  Pattern[/[1-9][0-9]*[KMG]B/] $log_file_size   = $kafka::broker::log_file_size,
  Integer[1, 50] $log_file_count                = $kafka::broker::log_file_count,
  Stdlib::Absolutepath $log_dir                 = $kafka::broker::log_dir,
) {
  assert_private()

  if ($manage_service and $service_restart) {
    $config_notify = Service[$service_name]
  } else {
    $config_notify = undef
  }

  $doctag = 'brokerconfigs'
  file { "${config_dir}/server.properties":
    ensure  => file,
    owner   => $user_name,
    group   => $group_name,
    mode    => $config_mode,
    content => template('kafka/properties.erb'),
    notify  => $config_notify,
    require => File[$config_dir],
  }

  if $manage_log4j {
    file { "${config_dir}/log4j.properties":
      ensure  => file,
      owner   => $user_name,
      group   => $group_name,
      mode    => $config_mode,
      content => epp('kafka/log4j.properties.epp', { 'log_file_size' => $log_file_size, 'log_file_count' => $log_file_count, 'log_dir' => $log_dir }),
      notify  => $config_notify,
      require => File[$config_dir],
    }
  }
}
