# frozen_string_literal: true

require "rails_helper"

RSpec.describe Shared::ModalComponent, type: :component do
  describe "#initialize" do
    it "accepts required title parameter" do
      component = described_class.new(title: "Delete Profile")
      expect(component.title).to eq("Delete Profile")
    end

    it "uses default value for confirm_text when not provided" do
      component = described_class.new(title: "Confirm")
      expect(component.confirm_text).to eq("Confirmar")
    end

    it "uses default value for cancel_text when not provided" do
      component = described_class.new(title: "Confirm")
      expect(component.cancel_text).to eq("Cancelar")
    end

    it "uses default value for confirm_method when not provided" do
      component = described_class.new(title: "Confirm")
      expect(component.confirm_method).to eq(:post)
    end

    it "accepts custom confirm_text" do
      component = described_class.new(title: "Delete", confirm_text: "Yes, Delete")
      expect(component.confirm_text).to eq("Yes, Delete")
    end

    it "accepts custom cancel_text" do
      component = described_class.new(title: "Delete", cancel_text: "No, Keep")
      expect(component.cancel_text).to eq("No, Keep")
    end
  end

  describe "#modal_id" do
    it "generates a unique ID when not provided" do
      component = described_class.new(title: "Modal")
      expect(component.modal_id).to match(/\Amodal-[0-9a-f]{8}\z/)
    end

    it "uses provided modal_id when specified" do
      component = described_class.new(title: "Modal", modal_id: "custom-modal-id")
      expect(component.modal_id).to eq("custom-modal-id")
    end

    it "generates different IDs for different instances" do
      component1 = described_class.new(title: "Modal 1")
      component2 = described_class.new(title: "Modal 2")

      expect(component1.modal_id).not_to eq(component2.modal_id)
    end
  end

  describe "#backdrop_classes" do
    it "includes fixed positioning and background classes" do
      component = described_class.new(title: "Modal")
      classes = component.backdrop_classes

      expect(classes).to include("fixed")
      expect(classes).to include("inset-0")
      expect(classes).to include("bg-black/50")
      expect(classes).to include("backdrop-blur-sm")
      expect(classes).to include("z-50")
    end
  end

  describe "#container_classes" do
    it "includes background and border classes" do
      component = described_class.new(title: "Modal")
      classes = component.container_classes

      expect(classes).to include("bg-slate-800")
      expect(classes).to include("border")
      expect(classes).to include("border-slate-700")
      expect(classes).to include("rounded-2xl")
    end
  end

  describe "#icon_container_classes" do
    it "includes background and rounded classes" do
      component = described_class.new(title: "Modal")
      classes = component.icon_container_classes

      expect(classes).to include("bg-red-500/20")
      expect(classes).to include("rounded-full")
      expect(classes).to include("flex")
    end
  end
end
