# frozen_string_literal: true

class RescanProfileJob < ApplicationJob
  include ProfileScrapingRetry

  queue_as :scraping
  sidekiq_options retry: 3, dead: false

  def perform(profile_id)
    profile = find_record_safely(Profile, profile_id)
    return unless profile

    log_event(:started, profile_id: profile_id)

    result = Profiles::RescanService.call(profile)

    handle_service_result(result, profile_id: profile_id)
  end
end
