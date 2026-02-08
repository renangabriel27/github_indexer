# frozen_string_literal: true

class UrlShortenerJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 3

  sidekiq_retry_in do |count, exception|
    case exception.message
    when /rate.limit/i
      60 + rand(30)  # 60-90 seconds for rate limit errors
    when /timeout/i
      [ 30, 120, 300 ][count - 1] || 300  # Exponential backoff for timeouts
    else
      :kill  # Don't retry for other errors
    end
  end

  GITHUB_URL = "https://github.com"

  def perform(profile_id)
    profile = Profile.find_by(id: profile_id)

    unless profile
      Rails.logger.warn("UrlShortenerJob: Profile##{profile_id} not found")
      return
    end

    Rails.logger.info("UrlShortenerJob: Starting for profile_id=#{profile_id}")

    github_url = "#{GITHUB_URL}/#{profile.github_username}"
    result = UrlShortenerService.call(github_url)

    if result.success?
      short_url = result.value![:short_url]
      profile.update_columns(short_github_url: short_url)
      Rails.logger.info("UrlShortenerJob: Success for profile_id=#{profile_id}, short_url=#{short_url}")
    else
      error = result.failure
      Rails.logger.error("UrlShortenerJob: Failed for profile_id=#{profile_id}, error=#{error[:error]}, message=#{error[:message]}")

      raise StandardError, error[:message] if error[:retryable]
    end
  end
end
