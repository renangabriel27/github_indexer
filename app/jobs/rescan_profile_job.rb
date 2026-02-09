# frozen_string_literal: true

class RescanProfileJob < ApplicationJob
  queue_as :scraping

  sidekiq_options retry: 3, dead: true, backtrace: 20

  sidekiq_retry_in do |count, exception|
    case exception
    when Ferrum::TimeoutError, Ferrum::DeadBrowserError
      # Browser issues: wait longer between retries
      [ 60, 180, 300 ][count - 1] || 300
    when Net::OpenTimeout, Net::ReadTimeout
      # Network issues: exponential backoff
      [ 30, 120, 300 ][count - 1] || 300
    when StandardError
      # Generic errors from service (check retryable flag)
      [ 10, 30, 60 ][count - 1] || 60
    else
      :kill  # Unknown error types - don't retry
    end
  end

  # Called when job fails after all retries are exhausted
  sidekiq_retries_exhausted do |job, _exception|
    profile_id = job["args"].first
    profile = Profile.find_by(id: profile_id)

    if profile
      profile.update(
        scraping_status: :failed,
        last_error: "Job failed after all retries",
        last_scanned_at: Time.current
      )

      # Broadcast failure to close the modal
      Profiles::Github::Broadcaster.new(profile).broadcast_error("Erro ao processar perfil após múltiplas tentativas")
    end
  end

  def perform(profile_id)
    profile = find_record_safely(Profile, profile_id)
    return unless profile

    log_event(:started, profile_id: profile_id)

    result = Profiles::RescanService.call(profile)

    handle_service_result(result, profile_id: profile_id)
  end
end
