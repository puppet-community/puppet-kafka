# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Define: kafka::topic
#
# This defined type is used to manage the creation of kafka topics.
#
define kafka::topic(
  String                        $ensure             = '',
  String                        $zookeeper          = '',
  Variant[Integer,String]       $replication_factor = 1,
  Variant[Integer,String]       $partitions         = 1,
  String                        $bin_dir            = '/opt/kafka/bin',
  String                        $kafka_dir          = '',
  String                        $kafka_log_dir      = '',
  Optional[Hash[String,String]] $config             = undef,
  Boolean                       $debug_cmds         = false,
) {

  if is_string($replication_factor) {
    deprication('kafka::topic', 'Please use Integer type, not String, for paramter replication_factor')
  }
  if is_string($partitions) {
    deprication('kafka::topic', 'Please use Integer type, not String, for paramter partitions')
  }

  $_zookeeper          = "--zookeeper ${zookeeper}"
  $_replication_factor = "--replication-factor ${replication_factor}"
  $_partitions         = "--partitions ${partitions}"

  if $config {
    $_config_array = $config.map |$key, $value| { "--config ${key}=${value}" }
    $_config = join($_config_array, ' ')
  } else {
    $_config = ''
  }

  $_kafka_topic_exe            = "kafka-topics.sh"
  $_onlyif_topicsconf_existing = "test `cat ${kafka_log_dir}/resultsTopicsConfig.txt | grep ${name} | grep -oE \"([a-z.]+)=([0-9]+)\" | while read; do conf_elem=$(echo \$REPLY|awk -F '=' '{print \"--config \"\$1\"=\"\$2}'); [[ \"${_config}\" =~ .*(\"\$conf_elem\").* ]] && echo ok || echo ko; done|grep ko|head -1|wc -l` -ne 0"
  $_onlyif_topicsconf_new      = "test `echo \"${_config}\"|grep -oE \"([a-z.]+)=([0-9]+)\"|while read; do conf_elem=$(echo \$REPLY|cut -d= -f1); [[ $(awk -F ' ' '{print $1}' ${kafka_log_dir}/resultsTopicsConfig.txt | grep ${name}) =~ (,|:)\"\$conf_elem\"(=) ]] && echo ko || echo ok; done|grep ok|head -1|wc -l` -ne 0"
  $_onlyif_topicsname          = "awk -F ' ' '{print $1}' ${kafka_log_dir}/resultsTopicsConfig.txt | grep ${name} >/dev/null"

  $_onlyif_update              = "${_onlyif_topicsname} && ${_onlyif_topicsconf_existing} || ${_onlyif_topicsconf_new}"
  $_unless_create              = "${_onlyif_topicsname}"
  $_onlyif_delete              = "${_onlyif_topicsname}"

  if $debug_cmds {
    notify { "_unless_create = ${_unless_create}": }
    notify { "_onlyif_delete = ${_onlyif_delete}": }
    notify { "_onlyif_update = ${_onlyif_update}": }
  }

  if $ensure == 'present' {

    exec { "create topic ${name}":
      path    => "/usr/bin:/usr/sbin/:/bin:/sbin:${bin_dir}",
      command => "kafka-topics.sh --create ${_zookeeper} ${_replication_factor} ${_partitions} --topic ${name} ${_config} || :",
      unless  => "${_unless_create}",
    } ->
    exec { "update topic ${name}":
      path    => "/usr/bin:/usr/sbin/:/bin:/sbin:${bin_dir}",
      command => "kafka-topics.sh --alter ${_zookeeper} ${_partitions} --topic ${name} ${_config} || kafka-topics.sh --alter ${_zookeeper} --topic ${name} ${_config} || :",
      onlyif  => "${_onlyif_update}",
    }
  }

  if $ensure == 'absent' {
    exec { "delete topic ${name}":
      path    => "/usr/bin:/usr/sbin/:/bin:/sbin:${bin_dir}",
      command => "kafka-topics.sh --delete ${_zookeeper} --topic ${name} || :",
      onlyif  => "${_onlyif_delete}",
    }
  }
}
