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

      context "when update_name is false" do
        subject(:extractor) { described_class.new(doc, update_name: false) }

        it "returns Success monad" do
          expect(extractor.call).to be_success
        end

        it "extracts username" do
          result = extractor.call.value!
          expect(result[:github_username]).to eq("torvalds")
        end

        it "does not include name in result" do
          result = extractor.call.value!
          expect(result).not_to have_key(:name)
        end
      end

      context "when update_name is true" do
        subject(:extractor) { described_class.new(doc, update_name: true) }

        it "extracts both username and name" do
          result = extractor.call.value!
          expect(result[:github_username]).to eq("torvalds")
          expect(result[:name]).to eq("Linus Torvalds")
        end
      end
    end

    context "with fallback selectors" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <span class="p-name">Guido van Rossum</span>
              <span class="vcard-username">gvanrossum</span>
            </body>
          </html>
        HTML
      end

      it "uses fallback selectors when primary selectors are not found" do
        extractor = described_class.new(doc, update_name: true)
        result = extractor.call.value!

        expect(result[:github_username]).to eq("gvanrossum")
        expect(result[:name]).to eq("Guido van Rossum")
      end
    end

    context "with missing elements" do
      let(:html) { "<html><body></body></html>" }

      it "returns nil for missing username" do
        extractor = described_class.new(doc, update_name: false)
        result = extractor.call.value!

        expect(result[:github_username]).to be_nil
      end

      it "returns nil for missing name when update_name is true" do
        extractor = described_class.new(doc, update_name: true)
        result = extractor.call.value!

        expect(result[:name]).to be_nil
      end
    end

    context "with whitespace in values" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <span itemprop="name">  John Doe  </span>
              <span itemprop="additionalName">  johndoe  </span>
            </body>
          </html>
        HTML
      end

      it "strips whitespace from username" do
        extractor = described_class.new(doc, update_name: false)
        result = extractor.call.value!

        expect(result[:github_username]).to eq("johndoe")
      end

      it "strips whitespace from name" do
        extractor = described_class.new(doc, update_name: true)
        result = extractor.call.value!

        expect(result[:name]).to eq("John Doe")
      end
    end
  end
end
