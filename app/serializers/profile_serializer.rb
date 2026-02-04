class ProfileSerializer < Blueprinter::Base
  identifier :id

  fields :name, :github_username, :short_github_url
  fields :followers, :following, :stars, :contributions_last_year
  fields :avatar_url, :location

  field :organizations do |profile|
    profile.organizations || []
  end

  field :created_at do |profile|
    profile.created_at.iso8601
  end
end