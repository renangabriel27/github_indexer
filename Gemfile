source "https://rubygems.org"

ruby "4.0.1"
gem "rails", "~> 8.1.2"
gem "bootsnap", require: false
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "propshaft"

# Frontend
gem "view_component"
gem "importmap-rails"

# Scraping
gem "nokogiri"
gem "ferrum"

# Background Jobs
gem "sidekiq"
gem "redis"

# API
gem "httparty"
gem "blueprinter"
gem "pagy"
gem "rswag-api"
gem "rswag-ui"

# Utilities
gem "dry-monads"
gem "ostruct"

# Rate limiting
gem "rack-attack"

group :development, :test do
  gem "rspec-rails"
  gem "rswag-specs"
  gem "factory_bot_rails"
  gem "faker"
  gem "byebug"
  gem "rubocop-rails-omakase", require: false
  gem "dotenv-rails"
end

group :test do
  gem "webmock"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "capybara"
  gem "selenium-webdriver"
  gem "database_cleaner-active_record"
end
