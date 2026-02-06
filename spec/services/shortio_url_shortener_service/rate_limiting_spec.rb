# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShortioUrlShortenerService, '#call - rate limiting' do
  include_context 'ShortioUrlShortenerService setup'

  describe 'rate limit monitoring' do
    it 'logs warning when rate limit is low' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 200,
          body: { 'shortURL' => 'https://go.short.io/test', 'originalURL' => long_url }.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '5' }
        )

      expect(Rails.logger).to receive(:warn).with('Short.io rate limit low: 5 remaining')

      service.call
    end

    it 'does not log warning when rate limit is above threshold' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 200,
          body: { 'shortURL' => 'https://go.short.io/test', 'originalURL' => long_url }.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '50' }
        )

      expect(Rails.logger).not_to receive(:warn)

      service.call
    end
  end
end
