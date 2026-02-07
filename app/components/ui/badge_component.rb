# frozen_string_literal: true

module Ui
  class BadgeComponent < ViewComponent::Base
    VARIANTS = {
      success: "bg-green-500/20 text-green-400 border border-green-500/30",
      warning: "bg-yellow-500/20 text-yellow-400 border border-yellow-500/30",
      danger: "bg-red-500/20 text-red-400 border border-red-500/30",
      info: "bg-blue-500/20 text-blue-400 border border-blue-500/30",
      default: "bg-gray-500/20 text-gray-400 border border-gray-500/30"
    }.freeze

    DOT_COLORS = {
      success: "bg-green-500",
      warning: "bg-yellow-500",
      danger: "bg-red-500",
      info: "bg-blue-500",
      default: "bg-gray-500"
    }.freeze

    attr_reader :text, :variant, :show_dot, :animate_dot

    def initialize(text:, variant: :default, show_dot: false, animate_dot: false)
      @text = text
      @variant = variant.to_sym
      @show_dot = show_dot
      @animate_dot = animate_dot

      raise ArgumentError, "Unknown variant: #{variant}" unless VARIANTS.key?(@variant)
    end

    def variant_classes
      VARIANTS[variant]
    end

    def base_classes
      "inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium"
    end

    def classes
      [ base_classes, variant_classes ].compact.join(" ")
    end

    def dot_color
      DOT_COLORS[variant]
    end

    def ping_classes
      classes = [ "animate-ping absolute inline-flex h-full w-full rounded-full opacity-75" ]
      classes << dot_color.gsub("bg-", "bg-").gsub("-500", "-400")
      classes.join(" ")
    end

    def dot_classes
      classes = [ "relative inline-flex rounded-full h-2 w-2" ]
      classes << dot_color
      classes.join(" ")
    end
  end
end
