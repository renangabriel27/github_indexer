# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::CardComponent, type: :component do
  describe "#followers_count and #stars_count - format_number logic" do
    context "when count is 0" do
      let(:profile) { build(:profile, followers: 0, stars: 0) }
      let(:component) { described_class.new(profile: profile) }

      it "returns '0' for followers" do
        expect(component.followers_count).to eq("0")
      end

      it "returns '0' for stars" do
        expect(component.stars_count).to eq("0")
      end
    end

    context "when count is less than 1000" do
      let(:profile) { build(:profile, followers: 999, stars: 500) }
      let(:component) { described_class.new(profile: profile) }

      it "returns the number as string for followers" do
        expect(component.followers_count).to eq("999")
      end

      it "returns the number as string for stars" do
        expect(component.stars_count).to eq("500")
      end
    end

    context "when count is exactly 1000" do
      let(:profile) { build(:profile, followers: 1000, stars: 1000) }
      let(:component) { described_class.new(profile: profile) }

      it "returns '1k' for followers" do
        expect(component.followers_count).to eq("1k")
      end

      it "returns '1k' for stars" do
        expect(component.stars_count).to eq("1k")
      end
    end

    context "when count has decimal (e.g., 1500)" do
      let(:profile) { build(:profile, followers: 1500, stars: 2500) }
      let(:component) { described_class.new(profile: profile) }

      it "returns '1.5k' for followers" do
        expect(component.followers_count).to eq("1.5k")
      end

      it "returns '2.5k' for stars" do
        expect(component.stars_count).to eq("2.5k")
      end
    end

    context "when count is round thousands (e.g., 2000)" do
      let(:profile) { build(:profile, followers: 2000, stars: 3000) }
      let(:component) { described_class.new(profile: profile) }

      it "returns '2k' for followers without decimal" do
        expect(component.followers_count).to eq("2k")
      end

      it "returns '3k' for stars without decimal" do
        expect(component.stars_count).to eq("3k")
      end
    end

    context "when count is 10000+" do
      let(:profile) { build(:profile, followers: 10000, stars: 15500) }
      let(:component) { described_class.new(profile: profile) }

      it "returns '10k' for followers" do
        expect(component.followers_count).to eq("10k")
      end

      it "returns '15.5k' for stars" do
        expect(component.stars_count).to eq("15.5k")
      end
    end

    context "when count is nil" do
      let(:profile) { build(:profile, followers: nil, stars: nil) }
      let(:component) { described_class.new(profile: profile) }

      it "returns '0' for followers" do
        expect(component.followers_count).to eq("0")
      end

      it "returns '0' for stars" do
        expect(component.stars_count).to eq("0")
      end
    end
  end

  describe "#avatar_url" do
    context "when profile has avatar_url" do
      let(:profile) { build(:profile, avatar_url: "https://example.com/avatar.png") }
      let(:component) { described_class.new(profile: profile) }

      it "returns the profile avatar_url" do
        expect(component.avatar_url).to eq("https://example.com/avatar.png")
      end
    end

    context "when profile avatar_url is nil" do
      let(:profile) { build(:profile, github_username: "johndoe", avatar_url: nil) }
      let(:component) { described_class.new(profile: profile) }

      it "returns GitHub identicon URL" do
        expect(component.avatar_url).to eq("https://github.com/identicons/johndoe.png")
      end
    end
  end

  describe "#display_name" do
    context "when profile has name" do
      let(:profile) { build(:profile, name: "John Doe", github_username: "johndoe") }
      let(:component) { described_class.new(profile: profile) }

      it "returns the profile name" do
        expect(component.display_name).to eq("John Doe")
      end
    end

    context "when profile name is nil" do
      let(:profile) { build(:profile, name: nil, github_username: "johndoe") }
      let(:component) { described_class.new(profile: profile) }

      it "returns the github_username" do
        expect(component.display_name).to eq("johndoe")
      end
    end
  end
end
