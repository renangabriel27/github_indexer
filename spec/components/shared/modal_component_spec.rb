# frozen_string_literal: true

require "rails_helper"

RSpec.describe Shared::ModalComponent, type: :component do
  describe "#initialize" do
    it "uses default values when not provided" do
      component = described_class.new(title: "Confirm")

      expect(component.title).to eq("Confirm")
      expect(component.confirm_text).to eq("Confirmar")
      expect(component.cancel_text).to eq("Cancelar")
      expect(component.confirm_method).to eq(:post)
    end

    it "accepts custom values" do
      component = described_class.new(title: "Delete", confirm_text: "Yes", cancel_text: "No")

      expect(component.confirm_text).to eq("Yes")
      expect(component.cancel_text).to eq("No")
    end
  end

  describe "#modal_id" do
    it "generates unique IDs when not provided" do
      component1 = described_class.new(title: "Modal 1")
      component2 = described_class.new(title: "Modal 2")

      expect(component1.modal_id).to match(/\Amodal-[0-9a-f]{8}\z/)
      expect(component1.modal_id).not_to eq(component2.modal_id)
    end

    it "uses provided modal_id when specified" do
      component = described_class.new(title: "Modal", modal_id: "custom-id")
      expect(component.modal_id).to eq("custom-id")
    end
  end
end
