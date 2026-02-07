# frozen_string_literal: true

module Ui
  class ButtonComponent < ViewComponent::Base
    VARIANTS = {
      primary: "bg-gradient-to-r from-indigo-500 to-purple-500 text-white font-semibold hover:shadow-lg hover:shadow-indigo-500/50 transition-all duration-200 hover:scale-105",
      secondary: "bg-slate-800 hover:bg-slate-700 border border-slate-700 text-white font-medium transition-all duration-200",
      danger: "bg-red-500/10 hover:bg-red-500/20 border border-red-500/30 text-red-400 font-medium transition-all duration-200"
    }.freeze

    attr_reader :text, :variant, :icon, :href, :method, :html_options

    def initialize(text:, variant: :primary, icon: nil, href: nil, method: nil, **html_options)
      @text = text
      @variant = variant.to_sym
      @icon = icon
      @href = href
      @method = method
      @html_options = html_options

      raise ArgumentError, "Unknown variant: #{variant}" unless VARIANTS.key?(@variant)
    end

    def variant_classes
      VARIANTS[variant]
    end

    def base_classes
      "inline-flex items-center gap-2 px-6 py-3 rounded-xl"
    end

    def classes
      [base_classes, variant_classes, html_options[:class]].compact.join(" ")
    end

    def link?
      href.present?
    end

    def button_options
      options = html_options.except(:class)
      options[:class] = classes

      if method.present? && !link?
        options[:method] = method
      end

      options
    end

    def link_options
      options = html_options.except(:class)
      options[:class] = classes

      if method.present?
        options[:data] ||= {}
        options[:data][:turbo_method] = method
      end

      options
    end

    def aria_label
      html_options[:"aria-label"] || (icon.present? && text.blank? ? "Button" : nil)
    end
  end
end
