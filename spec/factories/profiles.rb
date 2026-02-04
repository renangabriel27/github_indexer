FactoryBot.define do
  factory :profile do
    name { "MyString" }
    github_url { "MyString" }
    short_github_url { "MyString" }
    github_username { "MyString" }
    followers { 1 }
    following { 1 }
    stars { 1 }
    contributions_last_year { 1 }
    avatar_url { "MyString" }
    location { "MyString" }
    organizations { "" }
    scraping_status { "MyString" }
    last_error { "MyText" }
    last_scanned_at { "2026-02-03 22:19:00" }
  end
end
