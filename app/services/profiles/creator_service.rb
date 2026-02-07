# frozen_string_literal: true

module Profiles
  class CreatorService < ApplicationService
    def initialize(params)
      @params = params
    end

    def call
      profile = Profile.new(@params)

      return failure_result(profile) unless profile.save

      enqueue_jobs(profile)

      Success(profile: profile)
    end

    private

    def enqueue_jobs(profile)
      GithubScraperJob.perform_later(profile.id, update_name: false)
      UrlShortenerJob.perform_later(profile.id)
    end

    def failure_result(profile)
      Failure(
        error: :validation_failed,
        profile: profile,
        errors: profile.errors
      )
    end
  end
end
