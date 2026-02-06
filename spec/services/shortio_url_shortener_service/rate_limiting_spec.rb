# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShortioUrlShortenerService, 'rate limiting' do
  include_context 'ShortioUrlShortenerService setup'

  describe '#call' do
    context 'when rate limit is low' do
      before do
        stub_request(:post, 'https://api.short.io/links/public')
          .to_return(
            status: 200,
            body: {
              'shortURL' => 'https://go.short.io/test',
              'originalURL' => long_url
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
              'X-RateLimit-Remaining' => '5'
            }
          )
      end

      it 'logs a warning when rate limit is below 10' do
        expect(Rails.logger).to receive(:warn).with('Short.io rate limit low: 5 remaining')

        service.call
      end
    end

    context 'when rate limit is not low' do
      before do
        stub_request(:post, 'https://api.short.io/links/public')
          .to_return(
            status: 200,
            body: {
              'shortURL' => 'https://go.short.io/test',
              'originalURL' => long_url
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
              'X-RateLimit-Remaining' => '50'
            }
          )
      end

      it 'does not log a warning when rate limit is above 10' do
        expect(Rails.logger).not_to receive(:warn)

        service.call
      end
    end

    context 'when rate limit header is missing' do
      before do
        stub_request(:post, 'https://api.short.io/links/public')
          .to_return(
            status: 200,
            body: {
              'shortURL' => 'https://go.short.io/test',
              'originalURL' => long_url
            }.to_json,
            headers: {
              'Content-Type' => 'application/json'
            }
          )
      end

      it 'handles missing rate limit header gracefully and logs warning (nil.to_i = 0)' do
        expect(Rails.logger).to receive(:warn).with('Short.io rate limit low: 0 remaining')

        result = service.call

        expect(result[:success]).to be true
      end
    end
  end
end

