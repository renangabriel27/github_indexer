# frozen_string_literal: true

module Profiles
  class StatusBadgeComponent < ViewComponent::Base
    STATUS_VARIANTS = {
      "completed" => :success,
      "processing" => :info,
      "pending" => :warning,
      "failed" => :danger
    }.freeze

    attr_reader :status

    def initialize(status:)
      @status = status.to_s
    end

    def variant
      STATUS_VARIANTS.fetch(status, :default)
    end

    def animate?
      status == "processing"
    end

    def status_text
      I18n.t("activerecord.enums.profile.scraping_status.#{status}", default: status.humanize)
    end
  end
end
