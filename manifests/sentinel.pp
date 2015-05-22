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
# [*sentinel_args*]
#   Additional arguments to pass to the redis-sentinel command when launching.
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
# class { 'redis::sentinel':
#   sentinel_monitors => {
#     '0' => {
#       master-host => '127.0.0.1',
#       master-port => 6379,
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
  $sentinel_monitors     = $redis::params::sentinel_monitors,
  $sentinel_args         = $redis::params::sentinel_args,
  $sentinel_user         = $redis::params::sentinel_user
) {

  # Using Exec as a dependency here to avoid dependency cyclying when doing
  # Class['redis'] -> Redis::Sentinel[$name]
  Exec['install-redis'] -> Redis::Sentinel[$name]
  include redis

  file { "sentinel-init":
    ensure  => present,
    path    => "/etc/init.d/sentinel",
    mode    => '0755',
    content => template('redis/sentinel.init.erb'),
    notify  => Service["sentinel"],
  }

  file { "sentinel.conf":
    ensure  => present,
    path    => "/etc/redis/sentinel.conf",
    mode    => '0644',
    content => template('redis/sentinel.conf.erb'),
    owner   => $sentinel_user,
  }

  file { "sentinel.log":
    ensure  => present,
    path    => "/var/log/redis-sentinel.log",
    mode    => '0644',
    owner   => $sentinel_user,
  }

  service { "sentinel":
    ensure    => running,
    name      => "sentinel",
    enable    => true,
    require   => [ File["sentinel-init"], File["sentinel.conf"], File["sentinel.log"] ],
    subscribe => File["sentinel.conf"],
  }
}
