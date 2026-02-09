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
    {
      notice: { icon: :check_circle, text_color: "text-green-400" },
      alert: { icon: :exclamation_triangle, text_color: "text-yellow-400" },
      error: { icon: :exclamation_circle, text_color: "text-red-400" },
      info: { icon: :info_circle, text_color: "text-blue-400" }
    }.each do |type, expected|
      it "returns correct config for :#{type} type" do
        component = described_class.new(message: "Test", type: type)

        expect(component.config[:icon]).to eq(expected[:icon])
        expect(component.config[:text_color]).to eq(expected[:text_color])
      end
    end
  end

  describe "#flash_id" do
    it "generates unique IDs for different instances" do
      component1 = described_class.new(message: "Test 1", type: :notice)
      component2 = described_class.new(message: "Test 2", type: :notice)

      expect(component1.flash_id).to match(/\Aflash-[0-9a-f]{8}\z/)
      expect(component1.flash_id).not_to eq(component2.flash_id)
    end
  end
end
