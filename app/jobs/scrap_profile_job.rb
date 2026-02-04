class ScrapProfileJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(profile_id)
    profile = Profile.find(profile_id)

    result = Profiles::ScraperService.call(profile)
    nil unless result.success?
  end
end
