# frozen_string_literal: true

module Errors
  class PageComponent < ViewComponent::Base
    THEMES = {
      "500" => {
        glow: "bg-red-500/20",
        icon: :exclamation_circle,
        icon_color: "text-red-400",
        gradient: "from-red-400 to-pink-400"
      },
      "404" => {
        glow: "bg-indigo-500/20",
        icon: :x_circle,
        icon_color: "text-indigo-400",
        gradient: "from-indigo-400 to-purple-400"
      },
      "422" => {
        glow: "bg-yellow-500/20",
        icon: :exclamation_triangle,
        icon_color: "text-yellow-400",
        gradient: "from-yellow-400 to-orange-400"
      }
    }.freeze

    attr_reader :error_code, :error_type

    def initialize(error_code:, error_type:)
      @error_code = error_code
      @error_type = error_type

      raise ArgumentError, "Unknown error code: #{error_code}" unless THEMES.key?(error_code)
    end

    def theme
      THEMES[error_code]
    end

    def glow_class
      theme[:glow]
    end

    def icon_name
      theme[:icon]
    end

    def icon_color
      theme[:icon_color]
    end

    def gradient_class
      theme[:gradient]
    end

    def title
      I18n.t("errors.#{error_type}.title")
    end

    def message
      I18n.t("errors.#{error_type}.message")
    end

    def back_to_home_text
      I18n.t("errors.#{error_type}.back_to_home")
    end
  end
end
