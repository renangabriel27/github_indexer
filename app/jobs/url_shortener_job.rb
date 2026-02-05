class UrlShortenerJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 3

  def perform(profile_id)
    profile = Profile.find(profile_id)

    Rails.logger.info "=== UrlShortenerJob iniciado para profile_id: #{profile_id} ==="

    github_url = "https://www.github.com.br#{profile.github_username}"
    service = ShortioUrlShortenerService.new(github_url)
    short_github_url = service.call[:short_url]

    profile.update(short_github_url: short_github_url)
  end
end
