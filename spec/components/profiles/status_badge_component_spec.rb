# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::StatusBadgeComponent, type: :component do
  describe "#variant" do
    {
      "completed" => :success,
      "processing" => :info,
      "pending" => :warning,
      "failed" => :danger,
      "unknown" => :default
    }.each do |status, expected_variant|
      it "returns :#{expected_variant} for '#{status}' status" do
        expect(described_class.new(status: status).variant).to eq(expected_variant)
      end
    end
  end

  describe "#animate?" do
    it "returns true only for 'processing' status" do
      expect(described_class.new(status: "processing").animate?).to be true
      expect(described_class.new(status: "completed").animate?).to be false
    end
  end

  describe "#initialize" do
    it "accepts status as string or symbol" do
      expect(described_class.new(status: "completed").status).to eq("completed")
      expect(described_class.new(status: :pending).status).to eq("pending")
    end
  end
end
