require 'rails_helper'

RSpec.describe Profiles::Github::ScraperService, '#call' do
  include_context 'Ferrum browser setup'
  include_context 'GitHub HTML fixtures'
  include_context 'Profile GitHub API stubs'

  let(:profile) { create(:profile, github_username: 'torvalds') }
  let(:service) { described_class.new(profile, update_name: false) }

  describe 'successful scraping' do
    before { stub_browser_with_html(github_profile_html) }

    it 'returns Success with updated profile' do
      result = service.call

      expect(result).to be_success
      expect(result.value!).to eq(profile)
    end

    it 'extracts all profile fields correctly' do
      service.call
      profile.reload

      expect(profile.github_username).to eq('torvalds')
      expect(profile.followers).to eq(185_000)
      expect(profile.following).to eq(0)
      expect(profile.stars).to eq(25)
      expect(profile.contributions_last_year).to eq(4123)
      expect(profile.avatar_url).to include('avatars.githubusercontent.com')
      expect(profile.location).to eq('Portland, OR')
      expect(profile.organizations).to include('Linux Foundation')
    end

    it 'updates status to completed' do
      service.call
      profile.reload

      expect(profile.scraping_status).to eq('completed')
    end

    it 'closes the browser' do
      expect(browser_mock).to receive(:quit)
      service.call
    end
  end

  describe 'update_name parameter' do
    context 'when update_name is false' do
      let(:service) { described_class.new(profile, update_name: false) }

      before { stub_browser_with_html(github_profile_html) }

      it 'does not update the name field' do
        original_name = profile.name
        service.call
        profile.reload

        expect(profile.name).to eq(original_name)
      end
    end

    context 'when update_name is true' do
      let(:service) { described_class.new(profile, update_name: true) }

      before { stub_browser_with_html(github_profile_html) }

      it 'updates the name field' do
        service.call
        profile.reload

        expect(profile.name).to eq('Linus Torvalds')
      end
    end
  end
end
