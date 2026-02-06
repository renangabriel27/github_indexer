# frozen_string_literal: true

RSpec.shared_context 'Profile GitHub API stubs' do
  include ActiveJob::TestHelper
  def stub_github_api(username, type: 'User', status: 200)
    stub_request(:get, "https://api.github.com/users/#{username}")
      .to_return(
        status: status,
        body: { type: type }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  before do
    stub_request(:get, /https:\/\/api\.github\.com\/users\/\w+/)
      .to_return(
        status: 200,
        body: { type: 'User' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end

