OkComputer.mount_at = 'healthcheck'
OkComputer::Registry.register "sidekiq_check", OkComputer::SidekiqLatencyCheck.new("default")
OkComputer::Registry.register "redis_check", OkComputer::RedisCheck.new({:url => Settings.redis_url})
OkComputer::Registry.register "app_version_check", OkComputer::AppVersionCheck.new
OkComputer::Registry.register "ruby_version_check", OkComputer::RubyVersionCheck.new
OkComputer.make_optional %w(redis_check sidekiq_check app_version_check ruby_version_check )
