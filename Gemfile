source 'https://rubygems.org'

ruby '4.0.1'
gem 'rails', '~> 8.1.2'
gem 'bootsnap', require: false
gem 'pg', '~> 1.5'
gem 'puma', '>= 5.0'
gem 'propshaft'

# Frontend
gem 'tailwindcss-rails'
gem 'view_component'

# Scraping
gem 'nokogiri'
gem 'httparty'

# Background Jobs
gem 'sidekiq'

# API
gem 'blueprinter'
gem 'pagy'

# Utilities
gem 'dry-monads'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'rubocop-rails', require: false
end

group :test do
  gem 'webmock'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'capybara'
end

