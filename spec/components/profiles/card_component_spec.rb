# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::CardComponent, type: :component do
  describe "number formatting" do
    {
      0 => "0", nil => "0", 999 => "999",
      1000 => "1k", 1500 => "1.5k", 2000 => "2k", 15500 => "15.5k"
    }.each do |count, expected|
      it "formats #{count.inspect} as '#{expected}'" do
        profile = build(:profile, followers: count)
        expect(described_class.new(profile: profile).followers_count).to eq(expected)
      end
    end
  end

  describe "#avatar_url" do
    it "returns profile avatar_url when present" do
      profile = build(:profile, avatar_url: "https://example.com/avatar.png")
      expect(described_class.new(profile: profile).avatar_url).to eq("https://example.com/avatar.png")
    end

    it "returns GitHub identicon URL when avatar_url is nil" do
      profile = build(:profile, github_username: "johndoe", avatar_url: nil)
      expect(described_class.new(profile: profile).avatar_url).to eq("https://github.com/identicons/johndoe.png")
    end
  end

  describe "#display_name" do
    it "returns name when present, otherwise github_username" do
      expect(described_class.new(profile: build(:profile, name: "John", github_username: "john")).display_name).to eq("John")
      expect(described_class.new(profile: build(:profile, name: nil, github_username: "john")).display_name).to eq("john")
    end
  end
end
