# frozen_string_literal: true

module Profiles
  class CardComponent < ViewComponent::Base
    attr_reader :profile

    def initialize(profile:)
      @profile = profile
    end

    def card_classes
      "group relative bg-slate-800 border border-slate-700 rounded-2xl p-6 hover:bg-slate-750 hover:border-slate-600 transition-all duration-300 hover:shadow-xl hover:shadow-indigo-500/10 hover:-translate-y-1"
    end

    def action_container_classes
      "absolute top-4 right-4 z-10 flex items-center gap-2 opacity-0 md:group-hover:opacity-100 md:[@media(hover:none)]:opacity-100 transition-opacity duration-200"
    end

    def action_button_classes
      "p-2 bg-slate-700/80 hover:bg-slate-600 border border-slate-600 rounded-lg text-gray-400 hover:text-white transition-all duration-200 hover:scale-110 hover:shadow-lg"
    end

    def github_link_classes
      "inline-flex items-center gap-1.5 text-sm text-indigo-400 hover:text-indigo-300 transition-colors group/link truncate"
    end

    def username_classes
      "text-lg font-bold text-white truncate group-hover:text-indigo-400 transition-colors"
    end

    def name_container_classes
      "flex-1 min-w-0 pr-32 md:pr-0 md:group-hover:pr-32"
    end

    def stat_classes
      "flex items-center gap-1.5 text-gray-400"
    end

    def avatar_url
      profile.avatar_url || "https://github.com/identicons/#{profile.github_username}.png"
    end

    def display_name
      profile.name || profile.github_username
    end

    def followers_count
      format_number(profile.followers || 0)
    end

    def stars_count
      format_number(profile.stars || 0)
    end

    def formatted_date
      l(profile.created_at, format: :short)
    end

    private

    def format_number(number)
      return number.to_s if number < 1000

      value = number / 1000.0
      formatted = value % 1 == 0 ? value.to_i : format("%.1f", value)
      "#{formatted}k"
    end
  end
end
