# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::IconComponent, type: :component do
  describe "#initialize" do
    it "raises ArgumentError for unknown icon name" do
      expect { described_class.new(name: :invalid_icon, size: :md) }
        .to raise_error(ArgumentError, /Unknown icon: invalid_icon/)
    end

    it "raises ArgumentError for unknown size" do
      expect { described_class.new(name: :search, size: :huge) }
        .to raise_error(ArgumentError, /Unknown size: huge/)
    end
  end

  describe "#size_class" do
    it "returns correct class for :sm" do
      component = described_class.new(name: :search, size: :sm)
      expect(component.size_class).to eq("w-4 h-4")
    end

    it "returns correct class for :md (default)" do
      component = described_class.new(name: :search, size: :md)
      expect(component.size_class).to eq("w-5 h-5")
    end

    it "returns correct class for :lg" do
      component = described_class.new(name: :search, size: :lg)
      expect(component.size_class).to eq("w-6 h-6")
    end

    it "returns correct class for :xl" do
      component = described_class.new(name: :search, size: :xl)
      expect(component.size_class).to eq("w-8 h-8")
    end
  end

  describe "#fill_type" do
    it "returns 'currentColor' for :github icon" do
      component = described_class.new(name: :github)
      expect(component.fill_type).to eq("currentColor")
    end

    it "returns 'currentColor' for :star icon" do
      component = described_class.new(name: :star)
      expect(component.fill_type).to eq("currentColor")
    end

    it "returns 'none' for other icons" do
      component = described_class.new(name: :search)
      expect(component.fill_type).to eq("none")
    end
  end

  describe "#stroke_type" do
    it "returns 'none' for :github icon" do
      component = described_class.new(name: :github)
      expect(component.stroke_type).to eq("none")
    end

    it "returns 'none' for :star icon" do
      component = described_class.new(name: :star)
      expect(component.stroke_type).to eq("none")
    end

    it "returns 'currentColor' for other icons" do
      component = described_class.new(name: :search)
      expect(component.stroke_type).to eq("currentColor")
    end
  end

  describe "#classes" do
    it "returns only size_class when css_class is nil" do
      component = described_class.new(name: :search, size: :md)
      expect(component.classes).to eq("w-5 h-5")
    end

    it "combines size_class and css_class when both present" do
      component = described_class.new(name: :search, size: :lg, css_class: "text-blue-500")
      expect(component.classes).to eq("w-6 h-6 text-blue-500")
    end
  end
end
