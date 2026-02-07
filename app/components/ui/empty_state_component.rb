# frozen_string_literal: true

module Ui
  class EmptyStateComponent < ViewComponent::Base
    attr_reader :icon, :title, :description, :cta_text, :cta_url, :cta_icon

    def initialize(icon:, title:, description:, cta_text: nil, cta_url: nil, cta_icon: nil)
      @icon = icon
      @title = title
      @description = description
      @cta_text = cta_text
      @cta_url = cta_url
      @cta_icon = cta_icon
    end

    def container_classes
      "flex flex-col items-center justify-center py-32"
    end

    def icon_outer_container_classes
      "relative mb-8"
    end

    def icon_glow_classes
      "absolute inset-0 bg-indigo-500/20 blur-3xl rounded-full"
    end

    def icon_container_classes
      "relative bg-slate-800 p-8 rounded-3xl border border-slate-700"
    end

    def title_classes
      "text-2xl font-bold text-white mb-3"
    end

    def description_classes
      "text-gray-400 text-lg mb-8 max-w-md text-center"
    end

    def show_cta?
      cta_text.present? && cta_url.present?
    end
  end
end
