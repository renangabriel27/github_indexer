class UrlShortenerJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  GITHUB_URL = "https://github.com"

  def perform(profile_id)
    profile = Profile.find(profile_id)

    Rails.logger.info "=== UrlShortenerJob iniciado para profile_id: #{profile_id} ==="

    github_url = "#{GITHUB_URL}/#{profile.github_username}"
    service = ShortioUrlShortenerService.new(github_url)
    short_github_url = service.call[:short_url]

    profile.update_columns(short_github_url: short_github_url)
  end
end
