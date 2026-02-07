# frozen_string_literal: true

class ShortioUrlShortenerService < ApplicationService
  include HTTParty
  base_uri "https://api.short.io/links"

  TIMEOUT = 5

  class RateLimitExceededError < StandardError; end
  class ApiAuthenticationError < StandardError; end
  class DuplicateLinkError < StandardError; end

  def initialize(long_url)
    @long_url = long_url
    @api_key = ENV.fetch("SHORTIO_API_KEY")
    @domain = ENV.fetch("SHORTIO_DOMAIN", "go.short.io")
  end

  def call
    response = make_request
    check_rate_limit(response)
    parse_successful_response(response)
  rescue RateLimitExceededError => e
    Failure(error: :rate_limit_exceeded, message: e.message, retryable: true)
  rescue ApiAuthenticationError => e
    Failure(error: :authentication_failed, message: e.message, retryable: false)
  rescue DuplicateLinkError => e
    Failure(error: :duplicate_link, message: e.message, retryable: false)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Failure(error: :timeout, message: "Request timeout", retryable: true)
  rescue StandardError => e
    Rails.logger.error("ShortioUrlShortenerService error: #{e.message}")
    Failure(error: :unknown, message: e.message, retryable: false)
  end

  private

  def make_request
    response = self.class.post("/public", body: request_body.to_json, headers: headers, timeout: TIMEOUT)
    validate_response!(response)
    response
  end

  def validate_response!(response)
    case response.code
    when 200, 201 then nil
    when 401 then raise ApiAuthenticationError, "Invalid API Key"
    when 409 then raise DuplicateLinkError, "Link already exists"
    when 429 then raise RateLimitExceededError, "Rate limit exceeded"
    else raise StandardError, "Unexpected response: #{response.code}"
    end
  end

  def parse_successful_response(response)
    data = response.parsed_response
    Success(short_url: data["shortURL"], original_url: data["originalURL"])
  end

  def request_body
    {
      originalURL: @long_url,
      domain: @domain,
      allowDuplicates: false
    }
  end

  def headers
    {
      "Authorization" => @api_key,
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  def check_rate_limit(response)
    remaining = response.headers["X-RateLimit-Remaining"].to_i

    if remaining < 10
      Rails.logger.warn("Short.io rate limit low: #{remaining} remaining")
    end
  end
end
