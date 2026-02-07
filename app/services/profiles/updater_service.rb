# frozen_string_literal: true

module Profiles
  class UpdaterService < ApplicationService
    def initialize(profile, params)
      @profile = profile
      @params = params
    end

    def call
      username_changed = username_will_change?
      should_enqueue = username_changed && @profile.can_rescan?

      reset_scraping_data if username_changed

      return failure_result unless @profile.update(@params)

      enqueue_jobs if should_enqueue

      Success(profile: @profile)
    end

    private

    def username_will_change?
      @params[:github_username].present? &&
        @profile.github_username != @params[:github_username]
    end

    def reset_scraping_data
      @profile.assign_attributes(
        scraping_status: "pending",
        last_scanned_at: nil,
        last_error: nil
      )
    end

    def enqueue_jobs
      GithubScraperJob.perform_later(@profile.id, update_name: true)
      UrlShortenerJob.perform_later(@profile.id)
    end

    def failure_result
      Failure(
        error: :update_failed,
        profile: @profile,
        errors: @profile.errors
      )
    end
  end
end
