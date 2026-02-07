# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::CreatorService do
  subject(:service) { described_class.new(params) }

  let(:params) do
    {
      name: "Linus Torvalds",
      github_username: "torvalds"
    }
  end

  before do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  describe "#call" do
    context "when profile is valid" do
      it "returns success with profile" do
        result = service.call

        expect(result).to be_success
        expect(result.value![:profile]).to be_a(Profile)
        expect(result.value![:profile]).to be_persisted
      end

      it "creates a profile in the database" do
        expect { service.call }.to change(Profile, :count).by(1)
      end

      it "enqueues GithubScraperJob" do
        result = service.call
        profile = result.value![:profile]

        expect(GithubScraperJob).to have_been_enqueued.with(profile.id, update_name: false)
      end

      it "enqueues UrlShortenerJob" do
        result = service.call
        profile = result.value![:profile]

        expect(UrlShortenerJob).to have_been_enqueued.with(profile.id)
      end
    end

    context "when profile is invalid" do
      let(:params) do
        {
          name: "",
          github_username: ""
        }
      end

      it "returns failure with validation errors" do
        result = service.call

        expect(result).to be_failure
        expect(result.failure[:error]).to eq(:validation_failed)
        expect(result.failure[:profile]).to be_a(Profile)
        expect(result.failure[:profile]).not_to be_persisted
        expect(result.failure[:errors]).to be_present
      end

      it "does not create a profile" do
        expect { service.call }.not_to change(Profile, :count)
      end

      it "does not enqueue jobs" do
        service.call

        expect(GithubScraperJob).not_to have_been_enqueued
        expect(UrlShortenerJob).not_to have_been_enqueued
      end
    end

    context "when github_username has invalid format" do
      let(:params) do
        {
          name: "Test User",
          github_username: "-invalid"
        }
      end

      it "returns failure" do
        result = service.call

        expect(result).to be_failure
        expect(result.failure[:error]).to eq(:validation_failed)
      end
    end
  end
end
