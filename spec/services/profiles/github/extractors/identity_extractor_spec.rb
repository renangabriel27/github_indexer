# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Github::Extractors::IdentityExtractor do
  let(:doc) { Nokogiri::HTML(html) }

  describe "#call" do
    context "with valid profile HTML" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <span itemprop="name">Linus Torvalds</span>
              <span itemprop="additionalName">torvalds</span>
            </body>
          </html>
        HTML
      end

      it "extracts only username when update_name is false" do
        result = described_class.new(doc, update_name: false).call.value!

        expect(result[:github_username]).to eq("torvalds")
        expect(result).not_to have_key(:name)
      end

      it "extracts both username and name when update_name is true" do
        result = described_class.new(doc, update_name: true).call.value!

        expect(result[:github_username]).to eq("torvalds")
        expect(result[:name]).to eq("Linus Torvalds")
      end
    end

    context "with fallback selectors" do
      let(:html) do
        <<~HTML
          <html><body>
            <span class="p-name">Guido van Rossum</span>
            <span class="vcard-username">gvanrossum</span>
          </body></html>
        HTML
      end

      it "uses fallback selectors when primary selectors are not found" do
        result = described_class.new(doc, update_name: true).call.value!

        expect(result[:github_username]).to eq("gvanrossum")
        expect(result[:name]).to eq("Guido van Rossum")
      end
    end

    context "with missing elements" do
      let(:html) { "<html><body></body></html>" }

      it "returns nil for missing fields" do
        result = described_class.new(doc, update_name: true).call.value!

        expect(result[:github_username]).to be_nil
        expect(result[:name]).to be_nil
      end
    end
  end
end
