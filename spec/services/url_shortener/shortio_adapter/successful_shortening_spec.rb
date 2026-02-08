# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlShortener::ShortioAdapter, '#call - successful shortening' do
  include_context 'UrlShortener::ShortioAdapter setup'

  describe 'successful requests' do
    let(:short_url) { 'https://go.short.io/abc123' }
    let(:response_body) do
      {
        'shortURL' => short_url,
        'originalURL' => long_url
      }
    end

    before do
      stub_request(:post, 'https://api.short.io/links/public')
        .with(
          body: {
            originalURL: long_url,
            domain: domain,
            allowDuplicates: false
          }.to_json,
          headers: {
            'Authorization' => api_key,
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: response_body.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
        )
    end

    it 'returns success with short URL' do
      result = adapter.call

      expect(result).to be_success
      expect(result.value!).to eq(
        short_url: short_url,
        original_url: long_url
      )
    end

    it 'makes request with correct body and headers' do
      adapter.call

      expect(WebMock).to have_requested(:post, 'https://api.short.io/links/public')
        .with(
          body: {
            originalURL: long_url,
            domain: domain,
            allowDuplicates: false
          }.to_json,
          headers: {
            'Authorization' => api_key,
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }
        )
    end
  end
end
