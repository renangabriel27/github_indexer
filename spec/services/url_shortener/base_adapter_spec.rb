# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlShortener::BaseAdapter do
  let(:long_url) { 'https://github.com/testuser' }

  describe '#initialize' do
    it 'accepts a long_url parameter' do
      adapter = described_class.new(long_url)
      expect(adapter.instance_variable_get(:@long_url)).to eq(long_url)
    end
  end

  describe '#call' do
    it 'raises NotImplementedError' do
      adapter = described_class.new(long_url)

      expect do
        adapter.call
      end.to raise_error(NotImplementedError, /must implement #call/)
    end
  end
end
