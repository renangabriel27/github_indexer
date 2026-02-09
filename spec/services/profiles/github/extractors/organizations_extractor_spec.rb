# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Github::Extractors::OrganizationsExtractor do
  let(:doc) { Nokogiri::HTML(html) }
  subject(:extractor) { described_class.new(doc) }

  describe "#call" do
    context "with organizations using aria-label" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a itemprop="follows" href="/linux" aria-label="Linux Foundation">
                <img alt="@linux" src="...">
              </a>
              <a itemprop="follows" href="/rails" aria-label="Ruby on Rails">
                <img alt="@rails" src="...">
              </a>
            </body>
          </html>
        HTML
      end

      it "returns Success monad" do
        expect(extractor.call).to be_success
      end

      it "extracts organizations from aria-label" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq(["Linux Foundation", "Ruby on Rails"])
      end
    end

    context "with organizations using img alt fallback" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a itemprop="follows" href="/github">
                <img alt="@github" src="...">
              </a>
              <a itemprop="follows" href="/microsoft">
                <img alt="@microsoft" src="...">
              </a>
            </body>
          </html>
        HTML
      end

      it "extracts from img alt and removes @ prefix" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq(["github", "microsoft"])
      end
    end

    context "with mixed aria-label and img alt" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a itemprop="follows" href="/linux" aria-label="Linux Foundation">
                <img alt="@linux" src="...">
              </a>
              <a itemprop="follows" href="/github">
                <img alt="@github" src="...">
              </a>
            </body>
          </html>
        HTML
      end

      it "prefers aria-label over img alt" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq(["Linux Foundation", "github"])
      end
    end

    context "with duplicate organizations" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a itemprop="follows" href="/github" aria-label="GitHub">
                <img alt="@github" src="...">
              </a>
              <a itemprop="follows" href="/github" aria-label="GitHub">
                <img alt="@github" src="...">
              </a>
            </body>
          </html>
        HTML
      end

      it "removes duplicates" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq(["GitHub"])
      end
    end

    context "with no organizations" do
      let(:html) { "<html><body></body></html>" }

      it "returns empty array" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq([])
      end
    end

    context "with organization link missing both aria-label and img" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a itemprop="follows" href="/empty-org">
              </a>
            </body>
          </html>
        HTML
      end

      it "skips organizations without names" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq([])
      end
    end

    context "with blank organization names" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a itemprop="follows" href="/blank" aria-label="">
                <img alt="" src="...">
              </a>
              <a itemprop="follows" href="/valid" aria-label="Valid Org">
                <img alt="@valid" src="...">
              </a>
            </body>
          </html>
        HTML
      end

      it "filters out blank names" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq(["Valid Org"])
      end
    end

    context "with @ symbol in img alt" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a itemprop="follows" href="/org">
                <img alt="@my-org-name" src="...">
              </a>
            </body>
          </html>
        HTML
      end

      it "removes @ prefix from alt text" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq(["my-org-name"])
      end
    end

    context "with img alt without @ symbol" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a itemprop="follows" href="/org">
                <img alt="plain-name" src="...">
              </a>
            </body>
          </html>
        HTML
      end

      it "keeps name as is if no @ prefix" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq(["plain-name"])
      end
    end
  end
end
