module Profiles
  class CreatorService < ApplicationService
    def initialize(profile_params)
      @profile_params = profile_params
      @github_url = profile_params[:github_url]
    end

    def call
      Success(create)
    rescue StandardError => e
      Failure(e.message)
    end

    private

    attr_accessor :profile_params, :github_url

    def create
      url_shortener_service = ShortioUrlShortenerService.new(github_url)
      short_github_url = url_shortener_service.call[:short_url]
      profile = Profile.create!(profile_params.merge(short_github_url: short_github_url))
      scrapper = ScraperService.new(profile, github_url).call
      scrapper.value!
    end
  end
end
