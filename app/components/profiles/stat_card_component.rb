# frozen_string_literal: true

module Profiles
  class StatCardComponent < ViewComponent::Base
    STAT_CONFIG = {
      followers: {
        icon: :users,
        color: "text-indigo-400",
        label: "Followers"
      },
      following: {
        icon: :user_group,
        color: "text-purple-400",
        label: "Following"
      },
      stars: {
        icon: :star,
        color: "text-yellow-400",
        label: "Stars"
      },
      contributions: {
        icon: :chart_bar,
        color: "text-green-400",
        label: "Contribuições",
        tooltip: "Contribuições do último ano"
      }
    }.freeze

    attr_reader :stat_type, :value

    def initialize(stat_type:, value:)
      @stat_type = stat_type.to_sym
      @value = value

      raise ArgumentError, "Unknown stat type: #{stat_type}" unless STAT_CONFIG.key?(@stat_type)
    end

    def config
      STAT_CONFIG[stat_type]
    end

    def container_classes
      classes = ["bg-slate-900/50 rounded-xl p-6 text-center hover:bg-slate-900 transition-colors"]
      classes << "relative group" if config[:tooltip]
      classes.join(" ")
    end

    def icon_classes
      classes = ["w-8 h-8 mx-auto mb-3"]
      classes << config[:color]
      classes.join(" ")
    end

    def formatted_value
      # Use Rails number_with_delimiter helper
      ActionController::Base.helpers.number_with_delimiter(value)
    end

    def show_tooltip?
      config[:tooltip].present?
    end

    def tooltip_text
      config[:tooltip]
    end
  end
end
