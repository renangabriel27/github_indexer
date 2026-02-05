class GithubScraperJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(profile_id, update_name: false)
    profile = Profile.find(profile_id)

    Rails.logger.info "=== GithubScraperJob iniciado para profile_id: #{profile_id} ==="
    result = Profiles::ScraperService.call(profile, update_name: update_name)
    nil unless result.success?
  end
end
