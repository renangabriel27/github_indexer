# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::StatusBadgeComponent, type: :component do
  describe "#variant" do
    it "returns :success for 'completed' status" do
      component = described_class.new(status: "completed")
      expect(component.variant).to eq(:success)
    end

    it "returns :info for 'processing' status" do
      component = described_class.new(status: "processing")
      expect(component.variant).to eq(:info)
    end

    it "returns :warning for 'pending' status" do
      component = described_class.new(status: "pending")
      expect(component.variant).to eq(:warning)
    end

    it "returns :danger for 'failed' status" do
      component = described_class.new(status: "failed")
      expect(component.variant).to eq(:danger)
    end

    it "returns :default for unknown status" do
      component = described_class.new(status: "unknown_status")
      expect(component.variant).to eq(:default)
    end
  end

  describe "#animate?" do
    it "returns true for 'processing' status" do
      component = described_class.new(status: "processing")
      expect(component.animate?).to be true
    end

    it "returns false for 'completed' status" do
      component = described_class.new(status: "completed")
      expect(component.animate?).to be false
    end

    it "returns false for 'pending' status" do
      component = described_class.new(status: "pending")
      expect(component.animate?).to be false
    end

    it "returns false for 'failed' status" do
      component = described_class.new(status: "failed")
      expect(component.animate?).to be false
    end
  end

  describe "#initialize" do
    it "accepts status as string" do
      component = described_class.new(status: "completed")
      expect(component.status).to eq("completed")
    end

    it "accepts status as symbol and converts to string" do
      component = described_class.new(status: :pending)
      expect(component.status).to eq("pending")
    end
  end
end
