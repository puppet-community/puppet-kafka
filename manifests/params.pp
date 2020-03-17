# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class kafka::params
#
# This class is meant to be called from kafka::broker
# It sets variables according to platform
#
class kafka::params {

  # this is all only tested on Debian and RedHat
  # params gets included everywhere so we can do the validation here
  unless $facts['os']['family'] =~ /(RedHat|Debian)/ {
    warning("${facts['os']['family']} is not supported")
  }
  $version        = '0.11.0.3'
  $scala_version  = '2.11'
  $install_dir    = "/opt/kafka-${scala_version}-${version}"
  $config_dir     = '/opt/kafka/config'
  $bin_dir        = '/opt/kafka/bin'
  $log_dir        = '/var/log/kafka'
  $mirror_url     = 'https://www.apache.org/dyn/closer.lua?action=download&filename='
  $mirror_subpath = "kafka/${version}"
  $install_java   = false
  $package_dir    = '/var/tmp/kafka'
  $package_name   = undef
  $proxy_server   = undef
  $proxy_host     = undef
  $proxy_port     = undef
  $proxy_type     = undef
  $package_ensure = 'present'
  $user           = 'kafka'
  $group          = 'kafka'
  $user_id        = undef
  $group_id       = undef
  $system_user    = false
  $system_group   = false
  $manage_user    = true
  $manage_group   = true
  $config_mode    = '0644'
  $install_mode   = '0755'

  $service_install = true
  $service_ensure = 'running'
  $service_restart = true
  $service_requires = $facts['os']['family'] ? {
    'RedHat' => ['network.target', 'syslog.target'],
    default  => [],
  }
  $limit_nofile = undef
  $limit_core = undef
  $timeout_stop = undef
  $exec_stop = false
  $daemon_start = false

  $broker_heap_opts  = '-Xmx1G -Xms1G'
  $broker_jmx_port   = 9990
  $broker_jmx_opts   = "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=${broker_jmx_port}"
  $broker_log4j_opts = "-Dlog4j.configuration=file:${config_dir}/log4j.properties"
  $broker_opts       = ''

  $mirror_heap_opts    = '-Xmx256M'
  $mirror_jmx_port     = 9991
  $mirror_jmx_opts     = "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=${mirror_jmx_port}"
  $mirror_log4j_opts   = $broker_log4j_opts
  $mirror_service_name = 'kafka-mirror'

  $producer_jmx_port   = 9992
  $producer_jmx_opts   = "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=${producer_jmx_port}"
  $producer_log4j_opts = $broker_log4j_opts

  $consumer_jmx_port   = 9993
  $consumer_jmx_opts   = "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=${consumer_jmx_port}"
  $consumer_log4j_opts = $broker_log4j_opts

  $env                      = {}
  $consumer_config          = {}
  $producer_config          = {}
  $service_config           = {}
  $mirror_default_name      = 'default'
  $producer_properties_name = 'producer'
  $consumer_properties_name = 'consumer'
  $systemd_files_path       = '/etc/systemd/system'
}
