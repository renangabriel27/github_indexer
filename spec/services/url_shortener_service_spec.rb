# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlShortenerService do
  let(:long_url) { 'https://github.com/testuser' }

  describe '#initialize' do
    context 'when URL_SHORTENER_PROVIDER is not set' do
      before do
        allow(ENV).to receive(:fetch).with('URL_SHORTENER_PROVIDER', 'shortio').and_return('shortio')
      end

      it 'defaults to shortio adapter' do
        service = described_class.new(long_url)
        expect(service.instance_variable_get(:@adapter_class)).to eq(UrlShortener::ShortioAdapter)
      end
    end

    context 'when URL_SHORTENER_PROVIDER is set to shortio' do
      before do
        allow(ENV).to receive(:fetch).with('URL_SHORTENER_PROVIDER', 'shortio').and_return('shortio')
      end

      it 'uses shortio adapter' do
        service = described_class.new(long_url)
        expect(service.instance_variable_get(:@adapter_class)).to eq(UrlShortener::ShortioAdapter)
      end
    end

    context 'when URL_SHORTENER_PROVIDER is set to unknown provider' do
      before do
        allow(ENV).to receive(:fetch).with('URL_SHORTENER_PROVIDER', 'shortio').and_return('unknown')
      end

      it 'raises ArgumentError with helpful message' do
        expect do
          described_class.new(long_url)
        end.to raise_error(ArgumentError, /Unknown URL shortener provider: unknown/)
      end
    end
  end

  describe '#call' do
    let(:api_key) { 'test_api_key_123' }
    let(:domain) { 'go.short.io' }
    let(:short_url) { 'https://go.short.io/abc123' }

    before do
      allow(ENV).to receive(:fetch).with('URL_SHORTENER_PROVIDER', 'shortio').and_return('shortio')
      allow(ENV).to receive(:fetch).with('SHORTIO_API_KEY').and_return(api_key)
      allow(ENV).to receive(:fetch).with('SHORTIO_DOMAIN', 'go.short.io').and_return(domain)

      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 200,
          body: { 'shortURL' => short_url, 'originalURL' => long_url }.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
        )
    end

    it 'delegates to the configured adapter' do
      result = described_class.call(long_url)

      expect(result).to be_success
      expect(result.value![:short_url]).to eq(short_url)
      expect(result.value![:original_url]).to eq(long_url)
    end

    it 'passes through failure results from adapter' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 401,
          body: {}.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
        )

      result = described_class.call(long_url)

      expect(result).to be_failure
      expect(result.failure[:error]).to eq(:authentication_failed)
    end
  end
end
