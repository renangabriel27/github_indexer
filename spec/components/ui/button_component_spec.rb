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
    it "returns correct classes for :primary variant" do
      component = described_class.new(text: "Click", variant: :primary)
      expect(component.variant_classes).to include("bg-gradient-to-r", "from-indigo-500", "to-purple-500")
    end

    it "returns correct classes for :secondary variant" do
      component = described_class.new(text: "Click", variant: :secondary)
      expect(component.variant_classes).to include("bg-slate-800", "hover:bg-slate-700")
    end

    it "returns correct classes for :danger variant" do
      component = described_class.new(text: "Delete", variant: :danger)
      expect(component.variant_classes).to include("bg-red-500/10", "text-red-400")
    end
  end

  describe "#link?" do
    it "returns true when href is present" do
      component = described_class.new(text: "Link", href: "/some/path")
      expect(component.link?).to be true
    end

    it "returns false when href is nil" do
      component = described_class.new(text: "Button")
      expect(component.link?).to be false
    end
  end

  describe "#classes" do
    it "combines base_classes and variant_classes" do
      component = described_class.new(text: "Click", variant: :primary)
      classes = component.classes

      expect(classes).to include("inline-flex", "items-center", "gap-2")
      expect(classes).to include("bg-gradient-to-r")
    end

    it "includes html_options[:class] when provided" do
      component = described_class.new(text: "Click", class: "custom-class")
      expect(component.classes).to include("custom-class")
    end
  end

  describe "#aria_label" do
    it "returns provided aria-label when specified" do
      component = described_class.new(text: "Click", "aria-label": "Custom Label")
      expect(component.aria_label).to eq("Custom Label")
    end

    it "returns 'Button' when icon present and text is blank" do
      component = described_class.new(text: "", icon: :search)
      expect(component.aria_label).to eq("Button")
    end

    it "returns nil when text is present" do
      component = described_class.new(text: "Click Me")
      expect(component.aria_label).to be_nil
    end

    it "returns nil when no icon and no aria-label provided" do
      component = described_class.new(text: "Click")
      expect(component.aria_label).to be_nil
    end
  end

  describe "#link_options" do
    it "includes data-turbo-method when method is present" do
      component = described_class.new(text: "Delete", href: "/delete", method: :delete)
      options = component.link_options

      expect(options[:data]).to be_present
      expect(options[:data][:turbo_method]).to eq(:delete)
    end

    it "includes class attribute" do
      component = described_class.new(text: "Link", href: "/path")
      expect(component.link_options[:class]).to be_present
    end
  end

  describe "#button_options" do
    it "includes method when present and not a link" do
      component = described_class.new(text: "Submit", method: :post)
      options = component.button_options

      expect(options[:method]).to eq(:post)
    end

    it "does not include method when it is a link" do
      component = described_class.new(text: "Link", href: "/path", method: :delete)
      options = component.button_options

      expect(options[:method]).to be_nil
    end

    it "includes class attribute" do
      component = described_class.new(text: "Button")
      expect(component.button_options[:class]).to be_present
    end
  end
end
