# frozen_string_literal: true

module Api
  module V1
    class ProfileSerializer < Blueprinter::Base
      identifier :id

      fields :name, :github_username, :short_github_url
      fields :followers, :following, :stars, :contributions_last_year
      fields :avatar_url, :location

      field :organizations do |profile|
        profile.organizations || []
      end
    end
  end
end
