require 'simplecov'

SimpleCov.start 'rails' do
  add_filter 'channels'
  add_filter 'mailers'
end
