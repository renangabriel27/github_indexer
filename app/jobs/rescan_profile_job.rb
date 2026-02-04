class RescanProfileJob < ApplicationJob
  queue_as :default

  def perform(profile_id)
    profile = Profile.find(profile_id)
    return unless profile.can_rescan?

    Profiles::ScraperService.call(profile)
  end
end