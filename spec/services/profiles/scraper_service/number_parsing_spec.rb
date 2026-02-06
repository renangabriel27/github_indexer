require 'rails_helper'

RSpec.describe Profiles::ScraperService, '#call - number parsing' do
  include_context 'Ferrum browser setup'
  include_context 'GitHub HTML fixtures'
  include_context 'Profile GitHub API stubs'

  let(:profile) { create(:profile, github_username: 'testuser') }
  let(:service) { described_class.new(profile) }

  describe 'abbreviated number conversion' do
    shared_examples 'converts number correctly' do |display_value, expected_value|
      it "converts '#{display_value}' to #{expected_value}" do
        html = github_html_with_numbers(
          followers: display_value,
          following: '0',
          stars: '0',
          contributions: '0'
        )
        stub_browser_with_html(html)

        service.call
        expect(profile.reload.followers).to eq(expected_value)
      end
    end

    include_examples 'converts number correctly', '1k', 1_000
    include_examples 'converts number correctly', '7.7k', 7_700
    include_examples 'converts number correctly', '1.2M', 1_200_000
    include_examples 'converts number correctly', '42', 42
  end

  describe 'all numeric fields' do
    before do
      html = github_html_with_numbers(
        followers: '185k',
        following: '7.7k',
        stars: '1.2M',
        contributions: '4,123'
      )
      stub_browser_with_html(html)
    end

    it 'converts all numeric fields correctly' do
      service.call
      profile.reload

      expect(profile.followers).to eq(185_000)
      expect(profile.following).to eq(7_700)
      expect(profile.stars).to eq(1_200_000)
      expect(profile.contributions_last_year).to eq(4_123)
    end
  end
end
