# frozen_string_literal: true

module Profiles
  module Github
    class Broadcaster
      def initialize(profile)
        @profile = profile
      end

      def broadcast_status(status_key)
        return unless valid_status?(status_key)

        ProfileStatusChannel.broadcast_to(
          @profile,
          {
            action: "update_status",
            status: status_key,
            message: I18n.t("profiles.progress.#{status_key}")
          }
        )
      end

      def broadcast_completion
        @profile.reload # Ensure we have the latest data

        ProfileStatusChannel.broadcast_to(
          @profile,
          {
            action: "completed",
            message: I18n.t("profiles.progress.completed"),
            profile: profile_data
          }
        )
      end

      def broadcast_error(error_message)
        ProfileStatusChannel.broadcast_to(
          @profile,
          {
            action: "failed",
            message: I18n.t("profiles.progress.failed"),
            error: error_message
          }
        )
      end

      private

      def valid_status?(status_key)
        %i[preparing navigating loading collecting contributions finalizing].include?(status_key)
      end

      def profile_data
        {
          id: @profile.id,
          name: @profile.name,
          github_username: @profile.github_username,
          followers: @profile.followers,
          following: @profile.following,
          stars: @profile.stars,
          contributions_last_year: @profile.contributions_last_year,
          organizations: @profile.organizations,
          location: @profile.location,
          avatar_url: @profile.avatar_url
        }
      end
    end
  end
end
