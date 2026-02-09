Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5,
    pool_timeout: 5
  }

  # Limita concorrência da fila :scraping para reduzir uso de memória do Ferrum
  # Cada instância do Ferrum consome ~100MB RAM
  # Com concurrency 2, máximo 2 browsers simultâneos = ~200MB
  config.capsule("scraping") do |cap|
    cap.concurrency = 2
    cap.queues = [ "scraping" ]
  end

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
