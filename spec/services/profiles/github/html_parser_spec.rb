# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::Github::HtmlParser do
  let(:full_html) do
    <<~HTML
      <html>
        <head>
          <meta property="og:image" content="https://avatars.githubusercontent.com/u/1024025?v=4">
        </head>
        <body>
          <span itemprop="name">Linus Torvalds</span>
          <span itemprop="additionalName">torvalds</span>
          <img class="avatar-user" src="https://avatars.githubusercontent.com/u/1024025?s=64&v=4">
          <a href="/torvalds?tab=followers"><span class="text-bold">185k</span> followers</a>
          <a href="/torvalds?tab=following"><span class="text-bold">0</span> following</a>
          <a href="/torvalds?tab=stars"><span class="text-bold">50</span> stars</a>
          <h2 id="js-contribution-activity">4,123 contributions in the last year</h2>
          <div itemprop="homeLocation"><span class="p-label">Portland, OR</span></div>
          <a itemprop="follows" href="/linux" aria-label="Linux Foundation"><img alt="@linux"></a>
        </body>
      </html>
    HTML
  end

  describe '#parse' do
    it 'extracts all profile data correctly' do
      result = described_class.new(full_html, update_name: true).parse

      expect(result[:name]).to eq('Linus Torvalds')
      expect(result[:github_username]).to eq('torvalds')
      expect(result[:followers]).to eq(185_000)
      expect(result[:following]).to eq(0)
      expect(result[:stars]).to eq(50)
      expect(result[:contributions_last_year]).to eq(4_123)
      expect(result[:avatar_url]).to eq('https://avatars.githubusercontent.com/u/1024025?v=4')
      expect(result[:location]).to eq('Portland, OR')
      expect(result[:organizations]).to include('Linux Foundation')
    end

    it 'excludes name key when update_name is false' do
      result = described_class.new(full_html, update_name: false).parse
      expect(result).not_to have_key(:name)
    end

    context 'with minimal HTML' do
      let(:minimal_html) do
        <<~HTML
          <html>
            <span itemprop="name">John Doe</span>
            <span itemprop="additionalName">johndoe</span>
          </html>
        HTML
      end

      it 'returns zero or nil for missing optional fields' do
        result = described_class.new(minimal_html, update_name: true).parse

        expect(result[:name]).to eq('John Doe')
        expect(result[:github_username]).to eq('johndoe')
        expect(result[:followers]).to eq(0)
        expect(result[:avatar_url]).to be_nil
        expect(result[:organizations]).to eq([])
      end
    end
  end
end
