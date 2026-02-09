# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::ButtonComponent, type: :component do
  describe "#initialize" do
    it "raises ArgumentError for unknown variant" do
      expect { described_class.new(text: "Click me", variant: :invalid) }
        .to raise_error(ArgumentError, /Unknown variant: invalid/)
    end
  end

  describe "#variant_classes" do
    {
      primary: %w[bg-gradient-to-r from-indigo-500],
      secondary: %w[bg-slate-800 hover:bg-slate-700],
      danger: %w[bg-red-500/10 text-red-400]
    }.each do |variant, expected_classes|
      it "returns correct classes for :#{variant} variant" do
        component = described_class.new(text: "Click", variant: variant)
        expected_classes.each { |cls| expect(component.variant_classes).to include(cls) }
      end
    end
  end

  describe "#link?" do
    it "returns true when href is present, false otherwise" do
      expect(described_class.new(text: "Link", href: "/path").link?).to be true
      expect(described_class.new(text: "Button").link?).to be false
    end
  end

  describe "#aria_label" do
    it "returns provided aria-label when specified" do
      expect(described_class.new(text: "Click", "aria-label": "Custom").aria_label).to eq("Custom")
    end

    it "returns 'Button' when icon present and text is blank" do
      expect(described_class.new(text: "", icon: :search).aria_label).to eq("Button")
    end

    it "returns nil when text is present" do
      expect(described_class.new(text: "Click Me").aria_label).to be_nil
    end
  end
end
