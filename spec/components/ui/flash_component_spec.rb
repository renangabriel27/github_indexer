# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::FlashComponent, type: :component do
  describe "#initialize" do
    it "raises ArgumentError for unknown flash type" do
      expect { described_class.new(message: "Test", type: :unknown) }
        .to raise_error(ArgumentError, /Unknown flash type: unknown/)
    end
  end

  describe "#config" do
    it "returns correct config for :notice type" do
      component = described_class.new(message: "Success!", type: :notice)
      config = component.config

      expect(config[:icon]).to eq(:check_circle)
      expect(config[:text_color]).to eq("text-green-400")
      expect(config[:bg]).to eq("bg-green-500/10")
      expect(config[:border]).to eq("border-green-500/30")
    end

    it "returns correct config for :alert type" do
      component = described_class.new(message: "Warning!", type: :alert)
      config = component.config

      expect(config[:icon]).to eq(:exclamation_triangle)
      expect(config[:text_color]).to eq("text-yellow-400")
      expect(config[:bg]).to eq("bg-yellow-500/10")
    end

    it "returns correct config for :error type" do
      component = described_class.new(message: "Error!", type: :error)
      config = component.config

      expect(config[:icon]).to eq(:exclamation_circle)
      expect(config[:text_color]).to eq("text-red-400")
      expect(config[:border]).to eq("border-red-500/30")
    end

    it "returns correct config for :info type" do
      component = described_class.new(message: "Info!", type: :info)
      config = component.config

      expect(config[:icon]).to eq(:info_circle)
      expect(config[:text_color]).to eq("text-blue-400")
      expect(config[:hover_color]).to eq("hover:text-blue-300")
    end
  end

  describe "#container_classes" do
    it "includes base classes" do
      component = described_class.new(message: "Test", type: :notice)
      classes = component.container_classes

      expect(classes).to include("mb-6")
      expect(classes).to include("p-4")
      expect(classes).to include("rounded-xl")
      expect(classes).to include("flex")
    end

    it "includes config bg and border for notice type" do
      component = described_class.new(message: "Test", type: :notice)
      classes = component.container_classes

      expect(classes).to include("bg-green-500/10")
      expect(classes).to include("border-green-500/30")
    end
  end

  describe "#flash_id" do
    it "generates a unique ID in the format 'flash-XXXX'" do
      component = described_class.new(message: "Test", type: :notice)
      id = component.flash_id

      expect(id).to match(/\Aflash-[0-9a-f]{8}\z/)
    end

    it "returns the same ID on subsequent calls (memoization)" do
      component = described_class.new(message: "Test", type: :notice)
      first_id = component.flash_id
      second_id = component.flash_id

      expect(first_id).to eq(second_id)
    end

    it "generates different IDs for different component instances" do
      component1 = described_class.new(message: "Test 1", type: :notice)
      component2 = described_class.new(message: "Test 2", type: :notice)

      expect(component1.flash_id).not_to eq(component2.flash_id)
    end
  end
end
