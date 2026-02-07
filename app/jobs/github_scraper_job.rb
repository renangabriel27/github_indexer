# frozen_string_literal: true

class GithubScraperJob < ApplicationJob
  queue_as :scraping

  sidekiq_options retry: 3, dead: true, backtrace: 20

  sidekiq_retry_in do |count, exception|
    case exception
    when Ferrum::TimeoutError, Ferrum::DeadBrowserError
      # Browser issues: wait longer between retries
      [60, 180, 300][count - 1] || 300
    when Net::OpenTimeout, Net::ReadTimeout
      # Network issues: exponential backoff
      [30, 120, 300][count - 1] || 300
    when StandardError
      # Generic errors from service (check retryable flag)
      [10, 30, 60][count - 1] || 60
    else
      :kill
    end
  end

  def perform(profile_id, update_name: false)
    profile = find_record_safely(Profile, profile_id)
    return unless profile

    log_event(:started, profile_id: profile_id, update_name: update_name)

    result = Profiles::ScraperService.call(profile, update_name: update_name)

    handle_service_result(result, profile_id: profile_id)
  end
end
