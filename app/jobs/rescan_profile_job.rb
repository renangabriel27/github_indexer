class RescanProfileJob < ApplicationJob
  queue_as :default

  def perform(profile_id)
    profile = Profile.find(profile_id)
    return unless profile.can_rescan?
    github_url = "https://www.github.com/#{profile.github_username}"

    Profiles::ScraperService.call(profile, github_url)
  end
end
