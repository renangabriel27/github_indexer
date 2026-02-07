# frozen_string_literal: true

module Profiles
  class AvatarComponent < ViewComponent::Base
    SIZES = {
      sm: { container: "w-16 h-16", text: "text-2xl" },
      md: { container: "w-24 h-24", text: "text-3xl" },
      lg: { container: "w-32 h-32", text: "text-4xl" }
    }.freeze

    attr_reader :profile, :size

    def initialize(profile:, size: :lg)
      @profile = profile
      @size = size.to_sym

      raise ArgumentError, "Unknown size: #{size}" unless SIZES.key?(@size)
    end

    def size_config
      SIZES[size]
    end

    def outer_container_classes
      "relative group"
    end

    def glow_classes
      "absolute -inset-1 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full opacity-50 group-hover:opacity-75 transition"
    end

    def avatar_classes
      classes = ["relative rounded-full ring-4 ring-slate-700"]
      classes << size_config[:container]
      classes.join(" ")
    end

    def placeholder_classes
      classes = ["relative rounded-full ring-4 ring-slate-700 bg-slate-700 flex items-center justify-center"]
      classes << size_config[:container]
      classes.join(" ")
    end

    def initial_classes
      classes = ["text-gray-400"]
      classes << size_config[:text]
      classes.join(" ")
    end

    def avatar_url
      profile.avatar_url
    end

    def alt_text
      profile.name || profile.github_username
    end

    def initial
      name = profile.name.presence || profile.github_username
      name.first.upcase
    end
  end
end
