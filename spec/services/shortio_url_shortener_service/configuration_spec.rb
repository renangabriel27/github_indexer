# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShortioUrlShortenerService, 'configuration' do
  let(:long_url) { 'https://github.com/testuser' }
  let(:api_key) { 'test_api_key_123' }

  describe 'initialization' do
    context 'when SHORTIO_DOMAIN is provided' do
      let(:custom_domain) { 'custom.short.io' }

      before do
        allow(ENV).to receive(:fetch).with('SHORTIO_API_KEY').and_return(api_key)
        allow(ENV).to receive(:fetch).with('SHORTIO_DOMAIN', 'go.short.io').and_return(custom_domain)
      end

      it 'uses the custom domain' do
        service = described_class.new(long_url)

        stub_request(:post, 'https://api.short.io/links/public')
          .with(
            body: hash_including(domain: custom_domain)
          )
          .to_return(
            status: 200,
            body: { 'shortURL' => 'https://custom.short.io/test', 'originalURL' => long_url }.to_json,
            headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
          )

        service.call

        expect(WebMock).to have_requested(:post, 'https://api.short.io/links/public')
          .with(body: hash_including(domain: custom_domain))
      end
    end

    context 'when SHORTIO_DOMAIN is not provided' do
      before do
        allow(ENV).to receive(:fetch).with('SHORTIO_API_KEY').and_return(api_key)
        allow(ENV).to receive(:fetch).with('SHORTIO_DOMAIN', 'go.short.io').and_return('go.short.io')
      end

      it 'uses the default domain' do
        service = described_class.new(long_url)

        stub_request(:post, 'https://api.short.io/links/public')
          .with(
            body: hash_including(domain: 'go.short.io')
          )
          .to_return(
            status: 200,
            body: { 'shortURL' => 'https://go.short.io/test', 'originalURL' => long_url }.to_json,
            headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
          )

        service.call

        expect(WebMock).to have_requested(:post, 'https://api.short.io/links/public')
          .with(body: hash_including(domain: 'go.short.io'))
      end
    end

    context 'when SHORTIO_API_KEY is missing' do
      before do
        allow(ENV).to receive(:fetch).with('SHORTIO_API_KEY').and_raise(KeyError.new('key not found: "SHORTIO_API_KEY"'))
      end

      it 'raises KeyError' do
        expect do
          described_class.new(long_url)
        end.to raise_error(KeyError, /SHORTIO_API_KEY/)
      end
    end
  end
end
