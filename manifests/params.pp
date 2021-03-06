# == Class: redis::params
#
# Redis params.
#
# === Parameters
#
# === Authors
#
# Thomas Van Doren
#
# === Copyright
#
# Copyright 2012 Thomas Van Doren, unless otherwise noted.
#
class redis::params {
  $version = '2.8.12'
  $redis_port = '6379'
  $redis_bind_address = false
  $redis_src_dir = '/opt/redis-src'
  $redis_bin_dir = '/opt/redis'
  $redis_max_memory = '4gb'
  $redis_max_clients = false
  $redis_timeout = 300         # 0 = disabled
  $redis_loglevel = 'notice'
  $redis_databases = 16
  $redis_dir = '/var/lib/redis'
  $redis_slowlog_log_slower_than = 10000 # microseconds
  $redis_slowlog_max_len = 1024
  $redis_password = false
  $redis_slaveof_ip = false
  $redis_slave_priority = 100
  $redis_read_only_slave = 'yes'
  $redis_saves = ['save 900 1', 'save 300 10', 'save 60 10000']
  $redis_user = 'root'
  $redis_group = 'root'

  $sentinel_port = '26379'
  $sentinel_loglevel = 'notice'
  $sentinel_args = false
  $sentinel_monitors = {
    'mymaster' => {
      master-host => '127.0.0.1',
      master-port => 6379,
      quorum => 2,
      down-after-milliseconds => 30000,
      parallel-syncs => 1,
      failover-timeout => 180000
    }
  }
}
