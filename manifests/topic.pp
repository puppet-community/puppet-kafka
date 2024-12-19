# @summary
#   This defined type handles the creation of Kafka topics.
#
# @example Basic usage
#   kafka::topic { 'test':
#     ensure             => present,
#     zookeeper          => 'localhost:2181',
#     replication_factor => 1,
#     partitions         => 1,
#   }
#
# @param ensure
#   Should the topic be created.
#
# @param zookeeper
#   The connection string for the ZooKeeper connection in the form host:port.
#   Multiple hosts can be given to allow fail-over. Kafka < 3.0.0 only!
#
# @param bootstrap_server
#   The Kafka server to connect to in the form host:port. Kafka >= 2.2.0 only!
#
# @param replication_factor
#   The replication factor for each partition in the topic being created. If
#   not supplied, defaults to the cluster default.
#
# @param partitions
#   The number of partitions for the topic being created or altered. If not
#   supplied for create, defaults to the cluster default.
#
# @param bin_dir
#   The directory where the file kafka-topics.sh is located.
#
# @param config
#   A topic configuration override for the topic being created or altered.
#   See the Kafka documentation for full details on the topic configs.
#
# @param cmd_config
#   Property file containing configs to be passed to Admin Client.
#   This is used only with --bootstrap-server option for describing and
#   altering broker configs (e.g. specify sasl and ssl configs)
#
define kafka::topic (
  Optional[String[1]] $ensure                 = undef,
  Optional[String[1]] $zookeeper              = undef,
  Optional[String[1]] $bootstrap_server       = undef,
  Integer   $replication_factor               = 1,
  Integer   $partitions                       = 1,
  String[1] $bin_dir                          = '/opt/kafka/bin',
  Optional[Hash[String[1],String[1]]] $config = undef,
  Optional[Stdlib::Absolutepath] $cmd_config  = undef,
) {
  $_zookeeper          = "--zookeeper ${zookeeper}"
  $_bootstrap_server   = "--bootstrap-server ${bootstrap_server}"
  $_replication_factor = "--replication-factor ${replication_factor}"
  $_partitions         = "--partitions ${partitions}"

  if !$zookeeper and !$bootstrap_server {
    fail('Either zookeeper or bootstrap_server parameter must be defined!')
  }

  if $zookeeper and $cmd_config {
    warn('cmd_config will be ignored: This is used only with bootstrap_server')
  }

  if $zookeeper {
    $_connection = $_zookeeper
  } else {
    if $cmd_config {
      $_connection = "${_bootstrap_server} --command-config ${cmd_config}"
    } else {
      $_connection = $_bootstrap_server
    }
  }

  if $config {
    $_config_array = $config.map |$key, $value| { "--config ${key}=${value}" }
    $_config = join($_config_array, ' ')
  } else {
    $_config = ''
  }

  if $ensure == 'present' {
    exec { "create topic ${name}":
      path    => "/usr/bin:/usr/sbin/:/bin:/sbin:${bin_dir}",
      command => "kafka-topics.sh --create ${_connection} ${_replication_factor} ${_partitions} --topic ${name} ${_config}",
      unless  => "kafka-topics.sh --list ${_connection} | grep -x ${name}",
    }
  }
}
