# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::UpdaterService do
  subject(:service) { described_class.new(profile, params) }

  let(:profile) { create(:profile, github_username: "olduser") }

  before do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  describe "#call" do
    context "when updating without changing username" do
      let(:params) { { name: "New Name" } }

      it "returns success" do
        result = service.call

        expect(result).to be_success
        expect(result.value![:profile].name).to eq("New Name")
      end

      it "updates the profile" do
        service.call
        profile.reload

        expect(profile.name).to eq("New Name")
      end

      it "does not enqueue jobs" do
        service.call

        expect(GithubScraperJob).not_to have_been_enqueued
        expect(UrlShortenerJob).not_to have_been_enqueued
      end

      it "does not reset scraping data" do
        profile.update!(scraping_status: "completed", last_scanned_at: 1.hour.ago)
        original_status = profile.scraping_status
        original_scanned_at = profile.last_scanned_at

        service.call
        profile.reload

        expect(profile.scraping_status).to eq(original_status)
        expect(profile.last_scanned_at).to be_within(1.second).of(original_scanned_at)
      end
    end

    context "when changing username" do
      let(:params) { { github_username: "newuser" } }

      before do
        # Ensure profile can be rescanned (last scan was > 5 minutes ago)
        profile.update_columns(last_scanned_at: 10.minutes.ago)
      end

      it "returns success" do
        result = service.call

        expect(result).to be_success
        expect(result.value![:profile].github_username).to eq("newuser")
      end

      it "resets scraping data" do
        profile.update!(scraping_status: "completed", last_scanned_at: 1.hour.ago, last_error: "Some error")

        service.call
        profile.reload

        expect(profile.scraping_status).to eq("pending")
        expect(profile.last_scanned_at).to be_nil
        expect(profile.last_error).to be_nil
      end

      it "enqueues GithubScraperJob" do
        result = service.call

        expect(GithubScraperJob).to have_been_enqueued.with(profile.id, update_name: true)
      end

      it "enqueues UrlShortenerJob" do
        service.call

        expect(UrlShortenerJob).to have_been_enqueued.with(profile.id)
      end
    end

    context "when changing username but cannot rescan (within 5 minutes)" do
      let(:params) { { github_username: "newuser" } }

      before do
        profile.update!(last_scanned_at: 2.minutes.ago)
        # Clear jobs enqueued by the update above
        ActiveJob::Base.queue_adapter.enqueued_jobs.clear
      end

      it "returns failure with rate limit error" do
        result = service.call

        expect(result).to be_failure
        expect(result.failure[:error]).to eq(:rate_limit_exceeded)
        expect(result.failure[:profile]).to eq(profile)
      end

      it "includes time remaining in failure result" do
        result = service.call

        expect(result.failure[:time_remaining]).to be > 0
        expect(result.failure[:time_remaining]).to be <= 180 # 3 minutes in seconds
      end

      it "does not update the profile" do
        original_username = profile.github_username

        service.call
        profile.reload

        expect(profile.github_username).to eq(original_username)
      end

      it "does not enqueue jobs" do
        service.call

        expect(GithubScraperJob).not_to have_been_enqueued
        expect(UrlShortenerJob).not_to have_been_enqueued
      end

      it "does not reset scraping data" do
        profile.update!(scraping_status: "completed", last_error: "Some error")
        original_status = profile.scraping_status
        original_scanned_at = profile.last_scanned_at

        service.call
        profile.reload

        expect(profile.scraping_status).to eq(original_status)
        expect(profile.last_scanned_at).to be_within(1.second).of(original_scanned_at)
      end
    end

    context "when update fails validation" do
      let(:params) { { github_username: "-invalid" } }

      before do
        # Ensure profile can be rescanned so rate limit doesn't interfere
        profile.update_columns(last_scanned_at: 10.minutes.ago)
      end

      it "returns failure" do
        result = service.call

        expect(result).to be_failure
        expect(result.failure[:error]).to eq(:update_failed)
        expect(result.failure[:profile]).to eq(profile)
        expect(result.failure[:errors]).to be_present
      end

      it "does not update the profile" do
        original_username = profile.github_username

        service.call
        profile.reload

        expect(profile.github_username).to eq(original_username)
      end

      it "does not enqueue jobs" do
        service.call

        expect(GithubScraperJob).not_to have_been_enqueued
        expect(UrlShortenerJob).not_to have_been_enqueued
      end
    end
  end
end
