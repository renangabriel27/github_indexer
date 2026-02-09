# frozen_string_literal: true

module Profiles
  class ProgressModalComponent < ViewComponent::Base
    def initialize(profile:)
      @profile = profile
    end

    def render?
      processing_or_pending?
    end

    def processing_or_pending?
      @profile.scraping_status.in?(%w[pending processing])
    end

    def profile_id
      @profile.id
    end

    def current_status
      @profile.scraping_status
    end

    def status_message
      I18n.t("profiles.progress.preparing")
    end
  end
end
