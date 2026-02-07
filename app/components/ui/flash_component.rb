# frozen_string_literal: true

module Ui
  class FlashComponent < ViewComponent::Base
    TYPE_CONFIG = {
      notice: {
        variant: :success,
        icon: :check_circle,
        bg: "bg-green-500/10",
        border: "border-green-500/30",
        text_color: "text-green-400",
        hover_color: "hover:text-green-300"
      },
      alert: {
        variant: :warning,
        icon: :exclamation_triangle,
        bg: "bg-yellow-500/10",
        border: "border-yellow-500/30",
        text_color: "text-yellow-400",
        hover_color: "hover:text-yellow-300"
      },
      error: {
        variant: :danger,
        icon: :exclamation_circle,
        bg: "bg-red-500/10",
        border: "border-red-500/30",
        text_color: "text-red-400",
        hover_color: "hover:text-red-300"
      },
      info: {
        variant: :info,
        icon: :info_circle,
        bg: "bg-blue-500/10",
        border: "border-blue-500/30",
        text_color: "text-blue-400",
        hover_color: "hover:text-blue-300"
      }
    }.freeze

    attr_reader :message, :type

    def initialize(message:, type: :notice)
      @message = message
      @type = type.to_sym

      raise ArgumentError, "Unknown flash type: #{type}" unless TYPE_CONFIG.key?(@type)
    end

    def config
      TYPE_CONFIG[type]
    end

    def container_classes
      [
        "mb-6 p-4 rounded-xl flex items-center justify-between",
        config[:bg],
        "border",
        config[:border]
      ].join(" ")
    end

    def icon_classes
      [
        "w-5 h-5 flex-shrink-0",
        config[:text_color]
      ].join(" ")
    end

    def text_classes
      [
        "font-medium",
        config[:text_color]
      ].join(" ")
    end

    def button_classes
      [
        "transition-colors",
        config[:text_color],
        config[:hover_color]
      ].join(" ")
    end

    def flash_id
      @flash_id ||= "flash-#{SecureRandom.hex(4)}"
    end
  end
end
