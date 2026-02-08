# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::Github::HtmlParser do
  let(:html) do
    <<~HTML
      <html>
        <head>
          <title>Linus Torvalds - GitHub</title>
          <meta property="og:image" content="https://avatars.githubusercontent.com/u/1024025?v=4">
        </head>
        <body>
          <span itemprop="name">Linus Torvalds</span>
          <span itemprop="additionalName">torvalds</span>
          <img class="avatar-user" src="https://avatars.githubusercontent.com/u/1024025?s=64&v=4">

          <a href="/torvalds?tab=followers">
            <span class="text-bold">185k</span> followers
          </a>

          <a href="/torvalds?tab=following">
            <span class="text-bold">0</span> following
          </a>

          <a href="/torvalds?tab=stars">
            <span class="text-bold">50</span> stars
          </a>

          <h2 id="js-contribution-activity">4,123 contributions in the last year</h2>

          <div itemprop="homeLocation">
            <span class="p-label">Portland, OR</span>
          </div>

          <a itemprop="follows" href="/linux" aria-label="Linux Foundation">
            <img alt="@linux" src="...">
          </a>
          <a itemprop="follows" href="/torvalds-org">
            <img alt="@torvalds-org" src="...">
          </a>
        </body>
      </html>
    HTML
  end

  describe '#parse' do
    context 'when update_name is false' do
      subject(:parser) { described_class.new(html, update_name: false) }

      it 'returns parsed data without name key' do
        result = parser.parse

        expect(result).not_to have_key(:name)
        expect(result[:github_username]).to eq('torvalds')
        expect(result[:followers]).to eq(185_000)
        expect(result[:following]).to eq(0)
        expect(result[:stars]).to eq(50)
        expect(result[:contributions_last_year]).to eq(4123)
        expect(result[:avatar_url]).to eq('https://avatars.githubusercontent.com/u/1024025?v=4')
        expect(result[:location]).to eq('Portland, OR')
        expect(result[:organizations]).to eq([ 'Linux Foundation', 'torvalds-org' ])
      end
    end

    context 'when update_name is true' do
      subject(:parser) { described_class.new(html, update_name: true) }

      it 'returns parsed data including name key' do
        result = parser.parse

        expect(result[:name]).to eq('Linus Torvalds')
        expect(result[:github_username]).to eq('torvalds')
      end
    end

    context 'with fallback selectors' do
      let(:html) do
        <<~HTML
          <html>
            <span class="p-name">Jane Doe</span>
            <span class="vcard-username">janedoe</span>
            <a href="/janedoe?tab=followers">
              <span data-view-component="true" class="Counter">1.2M</span>
            </a>
            <a href="/janedoe?tab=following">
              <span data-view-component="true" class="Counter">500</span>
            </a>
            <a href="/janedoe?tab=stars">
              1234 stars
            </a>
          </html>
        HTML
      end

      subject(:parser) { described_class.new(html, update_name: true) }

      it 'uses fallback selectors correctly' do
        result = parser.parse

        expect(result[:name]).to eq('Jane Doe')
        expect(result[:github_username]).to eq('janedoe')
        expect(result[:followers]).to eq(1_200_000)
        expect(result[:following]).to eq(500)
        expect(result[:stars]).to eq(1234)
      end
    end

    context 'with missing optional fields' do
      let(:minimal_html) do
        <<~HTML
          <html>
            <span itemprop="name">John Doe</span>
            <span itemprop="additionalName">johndoe</span>
          </html>
        HTML
      end

      subject(:parser) { described_class.new(minimal_html, update_name: true) }

      it 'returns zero or nil for missing fields' do
        result = parser.parse

        expect(result[:name]).to eq('John Doe')
        expect(result[:github_username]).to eq('johndoe')
        expect(result[:followers]).to eq(0)
        expect(result[:following]).to eq(0)
        expect(result[:stars]).to eq(0)
        expect(result[:contributions_last_year]).to eq(0)
        expect(result[:avatar_url]).to be_nil
        expect(result[:location]).to be_nil
        expect(result[:organizations]).to eq([])
      end
    end
  end

  describe '#extract_counter_stat (DRY principle)' do
    let(:html_with_counters) do
      <<~HTML
        <html>
          <a href="/user?tab=followers">
            <span class="text-bold">7.7k</span>
          </a>
          <a href="/user?tab=following">
            <span data-view-component="true" class="Counter">250</span>
          </a>
          <a href="/user?tab=stars">
            999 starred repositories
          </a>
        </html>
      HTML
    end

    subject(:parser) { described_class.new(html_with_counters) }

    it 'extracts followers using .text-bold' do
      expect(parser.parse[:followers]).to eq(7700)
    end

    it 'extracts following using Counter component' do
      expect(parser.parse[:following]).to eq(250)
    end

    it 'extracts stars using text scanning fallback' do
      expect(parser.parse[:stars]).to eq(999)
    end
  end

  describe 'number parsing' do
    let(:html_template) do
      ->(number) do
        <<~HTML
          <html>
            <span itemprop="additionalName">user</span>
            <a href="/user?tab=followers">
              <span class="text-bold">#{number}</span>
            </a>
          </html>
        HTML
      end
    end

    [
      [ '1k', 1_000 ],
      [ '7.7k', 7_700 ],
      [ '1.2M', 1_200_000 ],
      [ '500', 500 ],
      [ '1,234', 1_234 ],
      [ '1,234,567', 1_234_567 ]
    ].each do |input, expected|
      it "parses '#{input}' as #{expected}" do
        parser = described_class.new(html_template.call(input))
        expect(parser.parse[:followers]).to eq(expected)
      end
    end
  end

  describe 'URL normalization' do
    let(:html_template) do
      ->(avatar_src) do
        <<~HTML
          <html>
            <span itemprop="additionalName">user</span>
            <img class="avatar-user" src="#{avatar_src}">
          </html>
        HTML
      end
    end

    it 'keeps full https URLs unchanged (except size param)' do
      parser = described_class.new(html_template.call('https://avatars.githubusercontent.com/u/123?s=64&v=4'))
      expect(parser.parse[:avatar_url]).to eq('https://avatars.githubusercontent.com/u/123?v=4')
    end

    it 'converts protocol-relative URLs' do
      parser = described_class.new(html_template.call('//avatars.githubusercontent.com/u/123'))
      expect(parser.parse[:avatar_url]).to eq('https://avatars.githubusercontent.com/u/123')
    end

    it 'converts relative paths to full GitHub URLs' do
      parser = described_class.new(html_template.call('/avatars/u/123'))
      expect(parser.parse[:avatar_url]).to eq('https://github.com/avatars/u/123')
    end
  end

  describe 'organizations extraction' do
    let(:html_with_orgs) do
      <<~HTML
        <html>
          <span itemprop="additionalName">user</span>
          <a itemprop="follows" href="/rails" aria-label="Ruby on Rails">
            <img alt="@rails" src="...">
          </a>
          <a itemprop="follows" href="/github">
            <img alt="@github" src="...">
          </a>
          <a itemprop="follows" href="/duplicate" aria-label="Duplicate Org">
            <img alt="@duplicate" src="...">
          </a>
          <a itemprop="follows" href="/duplicate" aria-label="Duplicate Org">
            <img alt="@duplicate" src="...">
          </a>
        </html>
      HTML
    end

    subject(:parser) { described_class.new(html_with_orgs) }

    it 'extracts unique organizations' do
      expect(parser.parse[:organizations]).to eq([ 'Ruby on Rails', 'github', 'Duplicate Org' ])
    end

    it 'prefers aria-label over img alt' do
      expect(parser.parse[:organizations].first).to eq('Ruby on Rails')
    end

    it 'removes duplicates' do
      expect(parser.parse[:organizations].count('Duplicate Org')).to eq(1)
    end
  end
end
