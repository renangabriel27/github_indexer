# frozen_string_literal: true

module Profiles
  class StatsGridComponent < ViewComponent::Base
    attr_reader :profile

    def initialize(profile:)
      @profile = profile
    end

    def container_classes
      "grid grid-cols-2 sm:grid-cols-4 gap-4 p-8 border-b border-slate-700"
    end

    def stats
      [
        { type: :followers, value: profile.followers },
        { type: :following, value: profile.following },
        { type: :stars, value: profile.stars },
        { type: :contributions, value: profile.contributions_last_year }
      ]
    end
  end
end
