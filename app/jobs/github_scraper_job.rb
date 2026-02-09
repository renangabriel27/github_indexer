# frozen_string_literal: true

class GithubScraperJob < ApplicationJob
  include ProfileScrapingRetry

  queue_as :scraping
  sidekiq_options retry: 3, dead: false

  def perform(profile_id, update_name: false)
    profile = find_record_safely(Profile, profile_id)
    return unless profile

    log_event(:started, profile_id: profile_id, update_name: update_name)

    result = Profiles::Github::ScraperService.call(profile, update_name: update_name)

    handle_service_result(result, profile_id: profile_id)
  end
end
