# frozen_string_literal: true

module Profiles
  class HeaderComponent < ViewComponent::Base
    attr_reader :profile

    def initialize(profile:)
      @profile = profile
    end

    def container_classes
      "relative bg-gradient-to-r from-indigo-900/50 to-purple-900/50 px-8 py-12 sm:px-12"
    end

    def flex_container_classes
      "flex flex-col sm:flex-row items-center sm:items-start gap-6"
    end

    def info_container_classes
      "flex-1 text-center sm:text-left"
    end

    def name_classes
      "text-4xl sm:text-5xl font-bold text-white mb-2"
    end

    def meta_container_classes
      "flex flex-wrap items-center justify-center sm:justify-start gap-3 mb-4"
    end

    def github_link_classes
      "inline-flex items-center gap-2 text-lg text-indigo-400 hover:text-indigo-300 transition-colors"
    end

    def location_container_classes
      classes = [ "inline-flex items-center gap-1.5 text-gray-400" ]
      classes << "hidden" unless profile.location.present?
      classes.join(" ")
    end

    def show_location?
      profile.location.present?
    end
  end
end
