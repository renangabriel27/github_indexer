# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::FormFieldComponent, type: :component do
  let(:profile) { Profile.new }
  let(:form) { double("form", object: profile) }

  subject(:component) do
    described_class.new(form: form, attribute: :github_username, label: "GitHub Username")
  end

  describe "#has_errors?" do
    it "returns true when object has errors on the attribute" do
      profile.errors.add(:github_username, "can't be blank")
      expect(component.has_errors?).to be true
    end

    it "returns false when object has no errors" do
      expect(component.has_errors?).to be false
    end
  end

  describe "#error_message" do
    it "returns the first error message for the attribute" do
      profile.errors.add(:github_username, "can't be blank")
      profile.errors.add(:github_username, "is invalid")
      expect(component.error_message).to eq("can't be blank")
    end
  end

  describe "#input_classes" do
    it "includes error classes when field has errors" do
      profile.errors.add(:github_username, "can't be blank")
      expect(component.input_classes).to include("border-red-500")
    end

    it "includes default classes when field has no errors" do
      expect(component.input_classes).to include("border-slate-600")
    end
  end
end
