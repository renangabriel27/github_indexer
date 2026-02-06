# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  include_context 'Profile GitHub API stubs'

  describe 'enums' do
    describe 'scraping_status' do
      it 'defines correct enum values' do
        expect(Profile.scraping_statuses.keys).to match_array(%w[pending processing completed failed])
      end

      it 'allows setting scraping_status to pending' do
        profile = create(:profile, scraping_status: :pending)
        expect(profile.pending?).to be true
      end

      it 'allows setting scraping_status to processing' do
        profile = create(:profile)
        profile.update_column(:scraping_status, :processing)
        profile.reload
        expect(profile.processing?).to be true
      end

      it 'allows setting scraping_status to completed' do
        profile = create(:profile)
        profile.update_column(:scraping_status, :completed)
        profile.reload
        expect(profile.completed?).to be true
      end

      it 'allows setting scraping_status to failed' do
        profile = create(:profile)
        profile.update_column(:scraping_status, :failed)
        profile.reload
        expect(profile.failed?).to be true
      end
    end
  end
end

