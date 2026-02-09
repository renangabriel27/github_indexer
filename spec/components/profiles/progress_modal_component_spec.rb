# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::ProgressModalComponent, type: :component do
  describe "#render?" do
    it "returns true when status is 'pending'" do
      profile = build(:profile, scraping_status: "pending")
      component = described_class.new(profile: profile)

      expect(component.render?).to be true
    end

    it "returns true when status is 'processing'" do
      profile = build(:profile, scraping_status: "processing")
      component = described_class.new(profile: profile)

      expect(component.render?).to be true
    end

    it "returns false when status is 'completed'" do
      profile = build(:profile, scraping_status: "completed")
      component = described_class.new(profile: profile)

      expect(component.render?).to be false
    end

    it "returns false when status is 'failed'" do
      profile = build(:profile, scraping_status: "failed")
      component = described_class.new(profile: profile)

      expect(component.render?).to be false
    end
  end

  describe "#processing_or_pending?" do
    it "returns true for 'pending' status" do
      profile = build(:profile, scraping_status: "pending")
      component = described_class.new(profile: profile)

      expect(component.processing_or_pending?).to be true
    end

    it "returns true for 'processing' status" do
      profile = build(:profile, scraping_status: "processing")
      component = described_class.new(profile: profile)

      expect(component.processing_or_pending?).to be true
    end

    it "returns false for 'completed' status" do
      profile = build(:profile, scraping_status: "completed")
      component = described_class.new(profile: profile)

      expect(component.processing_or_pending?).to be false
    end
  end

  describe "#profile_id" do
    it "exposes the profile id" do
      profile = build(:profile, id: 123)
      component = described_class.new(profile: profile)

      expect(component.profile_id).to eq(123)
    end
  end

  describe "#current_status" do
    it "exposes the current scraping_status" do
      profile = build(:profile, scraping_status: "processing")
      component = described_class.new(profile: profile)

      expect(component.current_status).to eq("processing")
    end
  end
end
