FactoryBot.define do
  factory :profile do
    name { Faker::Name.name }
    sequence(:github_username) { |n| "testuser#{n}" }
    sequence(:short_github_url) { |n| "https://githu.short.gy/#{SecureRandom.alphanumeric(6)}#{n}" }
    followers { Faker::Number.between(from: 0, to: 50_000) }
    following { Faker::Number.between(from: 0, to: 1_000) }
    stars { Faker::Number.between(from: 0, to: 10_000) }
    contributions_last_year { Faker::Number.between(from: 0, to: 2_000) }
    avatar_url { Faker::Avatar.image(slug: github_username, size: "200x200") }
    location { Faker::Address.city }
    organizations { [Faker::Company.name] }
    scraping_status { "completed" }
    last_error { nil }
    last_scanned_at { Time.current }
  end
end
