# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::FormFieldComponent, type: :component do
  let(:profile) { Profile.new }
  let(:form) { double("form", object: profile) }

  subject(:component) do
    described_class.new(
      form: form,
      attribute: :github_username,
      label: "GitHub Username"
    )
  end

  describe "#has_errors?" do
    context "when object has errors on the attribute" do
      before { profile.errors.add(:github_username, "can't be blank") }

      it "returns true" do
        expect(component.has_errors?).to be true
      end
    end

    context "when object has no errors on the attribute" do
      it "returns false" do
        expect(component.has_errors?).to be false
      end
    end
  end

  describe "#error_message" do
    it "returns the first error message for the attribute" do
      profile.errors.add(:github_username, "can't be blank")
      profile.errors.add(:github_username, "is invalid")

      expect(component.error_message).to eq("can't be blank")
    end
  end

  describe "#input_classes - padding" do
    it "includes prefix padding when prefix is present" do
      component_with_prefix = described_class.new(
        form: form,
        attribute: :github_username,
        label: "Username",
        prefix: "github.com/"
      )

      classes = component_with_prefix.input_classes
      expect(classes).to include("px-4 sm:pl-44 sm:pr-4 py-3.5")
    end

    it "includes icon padding when icon is present" do
      component_with_icon = described_class.new(
        form: form,
        attribute: :github_username,
        label: "Username",
        icon: :user
      )

      classes = component_with_icon.input_classes
      expect(classes).to include("pl-12 pr-4 py-3.5")
    end

    it "includes standard padding when no prefix or icon" do
      classes = component.input_classes
      expect(classes).to include("px-4 py-3.5")
    end
  end

  describe "#input_classes - border color" do
    context "when field has errors" do
      before { profile.errors.add(:github_username, "can't be blank") }

      it "includes error border color classes" do
        classes = component.input_classes
        expect(classes).to include("border-red-500")
        expect(classes).to include("focus:ring-red-500/50")
        expect(classes).to include("focus:border-red-500")
      end
    end

    context "when field has no errors" do
      it "includes default border color classes" do
        classes = component.input_classes
        expect(classes).to include("border-slate-600")
        expect(classes).to include("focus:ring-indigo-500/50")
        expect(classes).to include("focus:border-indigo-500")
      end
    end
  end

  describe "#input_classes - base classes" do
    it "includes all base classes" do
      classes = component.input_classes

      expect(classes).to include("w-full")
      expect(classes).to include("bg-slate-900/50")
      expect(classes).to include("border")
      expect(classes).to include("rounded-xl")
      expect(classes).to include("text-white")
    end
  end

  describe "#prefix_inner_classes" do
    it "includes background and border classes" do
      classes = component.prefix_inner_classes

      expect(classes).to include("bg-slate-900/80")
      expect(classes).to include("border-r")
      expect(classes).to include("border-slate-600")
      expect(classes).to include("rounded-l-xl")
    end
  end

  describe "#error_container_classes" do
    it "includes text-red-400 color" do
      classes = component.error_container_classes
      expect(classes).to include("text-red-400")
    end

    it "includes flex and gap classes" do
      classes = component.error_container_classes
      expect(classes).to include("flex")
      expect(classes).to include("items-center")
      expect(classes).to include("gap-1")
    end
  end

  describe "#help_text_classes" do
    it "includes text-gray-500 color" do
      classes = component.help_text_classes
      expect(classes).to eq("text-gray-500")
    end
  end

  describe "#icon_container_classes" do
    it "includes absolute positioning classes" do
      classes = component.icon_container_classes
      expect(classes).to include("absolute")
      expect(classes).to include("inset-y-0")
      expect(classes).to include("left-0")
    end

    it "includes pointer-events-none" do
      classes = component.icon_container_classes
      expect(classes).to include("pointer-events-none")
    end
  end
end
