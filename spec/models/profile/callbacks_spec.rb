# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  include_context 'Profile GitHub API stubs'

  describe 'callbacks' do
    describe 'before_validation :normalize_github_username' do
      it 'strips whitespace and converts to lowercase' do
        stub_github_api('username')
        profile = build(:profile, github_username: '  UserName  ')
        profile.valid?
        expect(profile.github_username).to eq('username')
      end
    end

    describe 'before_save :reset_scraping_data' do
      it 'resets scraping data when github_username changes' do
        profile = create(:profile, scraping_status: 'completed', last_scanned_at: 1.hour.ago, last_error: 'Some error')

        stub_github_api('newusername')

        profile.update(github_username: 'newusername')

        expect(profile.scraping_status).to eq('pending')
        expect(profile.last_scanned_at).to be_nil
        expect(profile.last_error).to be_nil
      end

      it 'does not reset scraping data when other attributes change' do
        profile = create(:profile, scraping_status: 'completed', last_scanned_at: 1.hour.ago)
        original_scanned_at = profile.last_scanned_at
        original_status = profile.scraping_status

        profile.update_columns(name: 'New Name')
        profile.reload

        expect(profile.scraping_status).to eq(original_status)
        expect(profile.last_scanned_at).to eq(original_scanned_at)
      end
    end

    describe 'after_create :enqueue_priority_jobs' do
      it 'enqueues scraper and shortener jobs on create' do
        expect do
          create(:profile)
        end.to have_enqueued_job(GithubScraperJob).and have_enqueued_job(UrlShortenerJob)
      end
    end

    describe 'after_update_commit :enqueue_priority_jobs' do
      it 'enqueues jobs when github_username changes' do
        profile = create(:profile)
        stub_github_api('newusername')

        expect do
          profile.update(github_username: 'newusername')
        end.to have_enqueued_job(GithubScraperJob).and have_enqueued_job(UrlShortenerJob)
      end
    end
  end
end

