# frozen_string_literal: true

module Profiles
  class RescanService < ApplicationService
    MINIMUM_INTERVAL = 5.minutes

    def initialize(profile)
      @profile = profile
    end

    def call
      unless can_rescan?
        return Failure(
          error: :rescan_too_soon,
          message: "Profile scanned #{time_since_scan} ago. Wait #{time_until_eligible}.",
          retryable: false
        )
      end

      Profiles::Github::ScraperService.call(@profile, update_name: true)
    end

    private

    def can_rescan?
      @profile.last_scanned_at.nil? ||
        @profile.last_scanned_at < MINIMUM_INTERVAL.ago
    end

    def time_since_scan
      return "never" if @profile.last_scanned_at.nil?

      distance = Time.current - @profile.last_scanned_at
      format_time_distance(distance)
    end

    def time_until_eligible
      return "now" unless @profile.last_scanned_at

      remaining = MINIMUM_INTERVAL - (Time.current - @profile.last_scanned_at)
      return "now" if remaining <= 0

      format_time_distance(remaining)
    end

    def format_time_distance(seconds)
      minutes = (seconds / 60).to_i
      if minutes < 1
        "#{seconds.to_i} seconds"
      elsif minutes == 1
        "1 minute"
      else
        "#{minutes} minutes"
      end
    end
  end
end
