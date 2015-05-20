# == Define: redis::sentinel
#
# Configure sentinel instance on an arbitrary port.
#
# === Parameters
#
# [*sentinel_port*]
#   Accept connections on this port.
#   Default: 26379
#
# [*sentinel_loglevel*]
#   Set the sentinel config value loglevel. Valid values are debug,
#   verbose, notice, and warning.
#   Default: notice
#
# [*sentinel_redis_password*]
#   Password used to connect to redis. Will be used if it is not nil.
#   Default: nil
#
# [*sentinel_monitors*]
#   Default is
# {
#   'mymaster' => {
#     master_host             => '127.0.0.1',
#     master_port             => 6379,
#     quorum                  => 2,
#     down-after-milliseconds => 30000,
#     parallel-syncs          => 1,
#     failover-timeout        => 180000,
#   },
# }
#   All information for one or more sentinel monitors in a Hashmap. Any
#   parameters other than master_host, master_port or quorum will be added to
#   the config file in their own stanza.
#
# === Examples
#
# redis::sentinel { 'sentinel':
#   sentinel_monitors => {
#     '0' => {
#       ip => 127.0.0.1,
#       port => 6379,
#       quorum => 2,
#       auth-pass => 'my secret password'
#     }
#   }
# }
#
define redis::sentinel (
  $sentinel_port         = $redis::params::sentinel_port,
  $sentinel_bind_address = $redis::params::sentinel_bind_address,
  $sentinel_loglevel     = $redis::params::sentinel_loglevel,
  $sentinel_loglevel     = $redis::params::sentinel_monitors
) {

  # Using Exec as a dependency here to avoid dependency cyclying when doing
  # Class['redis'] -> Redis::Instance[$name]
  Exec['install-redis'] -> Redis::Instance[$name]
  include redis

  file { "sentinel-init-${title}":
    ensure  => present,
    path    => "/etc/init.d/sentinel-${title}",
    mode    => '0755',
    content => template('redis/sentinel.init.erb'),
    notify  => Service["sentinel-${title}"],
  }
  file { "sentinel-${title}.conf":
    ensure  => present,
    path    => "/etc/redis/sentinel.${title}.conf",
    mode    => '0644',
    content => template('redis/sentinel.conf.erb'),
  }

  service { "sentinel-${title}":
    ensure    => running,
    name      => "sentinel-${title}",
    enable    => true,
    require   => [ File["sentinel-${title}.conf"], File["sentinel-init-${title}"] ],
    subscribe => File["sentinel-${title}.conf"],
  }
}
