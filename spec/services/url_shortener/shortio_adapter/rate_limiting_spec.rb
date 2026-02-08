# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlShortener::ShortioAdapter, '#call - rate limiting' do
  include_context 'UrlShortener::ShortioAdapter setup'

  let(:short_url) { 'https://go.short.io/abc123' }

  describe 'rate limit warnings' do
    it 'logs a warning when rate limit is low' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 200,
          body: { 'shortURL' => short_url, 'originalURL' => long_url }.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '5' }
        )

      allow(Rails.logger).to receive(:warn)

      adapter.call

      expect(Rails.logger).to have_received(:warn)
        .with('Short.io rate limit low: 5 remaining')
    end

    it 'does not log warning when rate limit is sufficient' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 200,
          body: { 'shortURL' => short_url, 'originalURL' => long_url }.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
        )

      allow(Rails.logger).to receive(:warn)

      adapter.call

      expect(Rails.logger).not_to have_received(:warn)
    end
  end
end
