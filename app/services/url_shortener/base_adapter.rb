# frozen_string_literal: true

module UrlShortener
  class BaseAdapter < ApplicationService
    def initialize(long_url)
      @long_url = long_url
    end

    def call
      raise NotImplementedError, "#{self.class} must implement #call"
    end

    # Interface Contract:
    # All adapters must return:
    #   Success(short_url: String, original_url: String)
    #   Failure(error: Symbol, message: String, retryable: Boolean)
    #
    # Possible error types:
    #   :rate_limit_exceeded, :authentication_failed, :duplicate_link,
    #   :timeout, :unknown
  end
end
