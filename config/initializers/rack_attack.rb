# frozen_string_literal: true

class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  # Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_URL'])

  throttle("api/ip", limit: 100, period: 1.hour) do |req|
    if req.path.start_with?("/api/")
      req.ip
    end
  end

  throttle("api/search/ip", limit: 50, period: 1.hour) do |req|
    if req.path.start_with?("/api/") && (req.params["search"].present? || req.params["q"].present?)
      req.ip
    end
  end

  ### Whitelist & Blacklist ###

  safelist("allow-localhost") do |req|
    Rails.env.development? && [ "127.0.0.1", "::1" ].include?(req.ip)
  end

  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.warn("[Rack::Attack] Rate limit exceeded for IP: #{req.ip} - Path: #{req.path}")
  end

  ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.error("[Rack::Attack] Blocked IP: #{req.ip} - Path: #{req.path}")
  end
end
