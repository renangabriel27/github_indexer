# frozen_string_literal: true

class UrlShortenerService < ApplicationService
  ADAPTER_MAP = {
    'shortio' => UrlShortener::ShortioAdapter
    # Add new adapters here:
    # 'bitly'   => UrlShortener::BitlyAdapter,
    # 'tinyurl' => UrlShortener::TinyUrlAdapter
  }.freeze

  def initialize(long_url)
    @long_url = long_url
    @adapter_class = ADAPTER_MAP.fetch(provider_name) do
      raise ArgumentError, "Unknown URL shortener provider: #{provider_name}. Available: #{ADAPTER_MAP.keys.join(', ')}"
    end
  end

  def call
    @adapter_class.call(@long_url)
  end

  private

  def provider_name
    ENV.fetch('URL_SHORTENER_PROVIDER', 'shortio')
  end
end
