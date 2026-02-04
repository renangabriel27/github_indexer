require 'rails_helper'

RSpec.describe Profile, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:github_url) }

  describe '.search' do
    let!(:profile) { create(:profile, name: 'Matz') }

    it 'finds by name' do
      expect(Profile.search('Matz')).to include(profile)
    end
  end

  describe '#can_rescan?' do
    it 'allows after 5 minutes' do
      profile = create(:profile, last_scanned_at: 10.minutes.ago)
      expect(profile.can_rescan?).to be true
    end
  end
end
