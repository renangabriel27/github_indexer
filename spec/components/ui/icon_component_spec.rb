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
    { sm: "w-4 h-4", md: "w-5 h-5", lg: "w-6 h-6", xl: "w-8 h-8" }.each do |size, expected|
      it "returns #{expected} for :#{size}" do
        expect(described_class.new(name: :search, size: size).size_class).to eq(expected)
      end
    end
  end

  describe "#fill_type and #stroke_type" do
    it "returns currentColor fill and none stroke for filled icons" do
      %i[github star].each do |icon|
        component = described_class.new(name: icon)
        expect(component.fill_type).to eq("currentColor")
        expect(component.stroke_type).to eq("none")
      end
    end

    it "returns none fill and currentColor stroke for stroke icons" do
      component = described_class.new(name: :search)
      expect(component.fill_type).to eq("none")
      expect(component.stroke_type).to eq("currentColor")
    end
  end
end
