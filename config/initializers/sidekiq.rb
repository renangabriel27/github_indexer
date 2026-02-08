Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5,
    pool_timeout: 5
  }

  config.on(:startup) do
    Rails.logger.info "Sidekiq server started - queues: #{config.queues}"
  end

  config.on(:shutdown) do
    Rails.logger.info "Sidekiq server shutting down"
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5,
    pool_timeout: 5
  }
end
