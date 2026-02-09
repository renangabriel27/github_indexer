# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::ProgressModalComponent, type: :component do
  describe "#render? and #processing_or_pending?" do
    %w[pending processing].each do |status|
      it "returns true for '#{status}' status" do
        component = described_class.new(profile: build(:profile, scraping_status: status))
        expect(component.render?).to be true
        expect(component.processing_or_pending?).to be true
      end
    end

    %w[completed failed].each do |status|
      it "returns false for '#{status}' status" do
        component = described_class.new(profile: build(:profile, scraping_status: status))
        expect(component.render?).to be false
      end
    end
  end

  describe "#profile_id and #current_status" do
    it "exposes profile attributes" do
      profile = build(:profile, id: 123, scraping_status: "processing")
      component = described_class.new(profile: profile)

      expect(component.profile_id).to eq(123)
      expect(component.current_status).to eq("processing")
    end
  end
end
