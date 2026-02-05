class RescanProfileJob < ApplicationJob
  queue_as :default

  def perform(profile_id)
    profile = Profile.find(profile_id)
    return unless profile.can_rescan?

    profile.update(scraping_status: :processing)
    Profiles::ScraperService.call(profile)
  end
end
