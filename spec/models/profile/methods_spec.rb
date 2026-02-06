# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  include_context 'Profile GitHub API stubs'

  describe '#can_rescan?' do
    it 'returns true when last_scanned_at is nil' do
      profile = create(:profile, last_scanned_at: nil)
      expect(profile.can_rescan?).to be true
    end

    it 'returns true when last_scanned_at is more than 5 minutes ago' do
      profile = create(:profile, last_scanned_at: 10.minutes.ago)
      expect(profile.can_rescan?).to be true
    end

    it 'returns false when last_scanned_at is less than 5 minutes ago' do
      profile = create(:profile)
      scanned_time = 2.minutes.ago
      profile.update_column(:last_scanned_at, scanned_time)
      profile.reload

      expect(profile.last_scanned_at).to be > 5.minutes.ago
      expect(profile.can_rescan?).to be false
    end
  end

  describe '.search' do
    before do
      stub_github_api('matz')
      stub_github_api('dhh')
      stub_github_api('rails')
    end

    let!(:profile1) { create(:profile, name: 'Matz', github_username: 'matz') }
    let!(:profile2) { create(:profile, name: 'DHH', github_username: 'dhh') }
    let!(:profile3) { create(:profile, name: 'Rails', github_username: 'rails', location: 'San Francisco') }

    it 'finds profiles by name' do
      results = Profile.search('Matz')
      expect(results).to include(profile1)
      expect(results).not_to include(profile2)
    end

    it 'finds profiles by github_username' do
      results = Profile.search('dhh')
      expect(results).to include(profile2)
      expect(results).not_to include(profile1)
    end

    it 'finds profiles by location' do
      results = Profile.search('San Francisco')
      expect(results).to include(profile3)
    end

    it 'is case insensitive' do
      results = Profile.search('MATZ')
      expect(results).to include(profile1)
    end

    it 'returns all profiles when query is blank' do
      results = Profile.search('')
      expect(results.count).to eq(3)
    end

    it 'returns all profiles when query is nil' do
      results = Profile.search(nil)
      expect(results.count).to eq(3)
    end
  end
end

