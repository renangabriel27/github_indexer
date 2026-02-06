# frozen_string_literal: true

RSpec.shared_context 'ShortioUrlShortenerService setup' do
  let(:long_url) { 'https://github.com/testuser' }
  let(:api_key) { 'test_api_key_123' }
  let(:domain) { 'go.short.io' }
  let(:service) { described_class.new(long_url) }

  before do
    allow(ENV).to receive(:fetch).with('SHORTIO_API_KEY').and_return(api_key)
    allow(ENV).to receive(:fetch).with('SHORTIO_DOMAIN', 'go.short.io').and_return(domain)
  end
end
