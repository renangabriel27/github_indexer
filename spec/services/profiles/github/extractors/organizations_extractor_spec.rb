# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Github::Extractors::OrganizationsExtractor do
  let(:doc) { Nokogiri::HTML(html) }
  subject(:extractor) { described_class.new(doc) }

  describe "#call" do
    context "with organizations" do
      let(:html) do
        <<~HTML
          <html><body>
            <a itemprop="follows" href="/linux" aria-label="Linux Foundation"><img alt="@linux" src="..."></a>
            <a itemprop="follows" href="/github"><img alt="@github" src="..."></a>
          </body></html>
        HTML
      end

      it "extracts organizations preferring aria-label over img alt" do
        result = extractor.call.value!
        expect(result[:organizations]).to eq([ "Linux Foundation", "github" ])
      end
    end

    context "with duplicate organizations" do
      let(:html) do
        <<~HTML
          <html><body>
            <a itemprop="follows" href="/github" aria-label="GitHub"><img alt="@github"></a>
            <a itemprop="follows" href="/github" aria-label="GitHub"><img alt="@github"></a>
          </body></html>
        HTML
      end

      it "removes duplicates" do
        expect(extractor.call.value![:organizations]).to eq([ "GitHub" ])
      end
    end

    context "with no organizations" do
      let(:html) { "<html><body></body></html>" }

      it "returns empty array" do
        expect(extractor.call.value![:organizations]).to eq([])
      end
    end

    context "with blank organization names" do
      let(:html) do
        <<~HTML
          <html><body>
            <a itemprop="follows" href="/blank" aria-label=""><img alt="" src="..."></a>
            <a itemprop="follows" href="/valid" aria-label="Valid Org"><img alt="@valid"></a>
          </body></html>
        HTML
      end

      it "filters out blank names" do
        expect(extractor.call.value![:organizations]).to eq([ "Valid Org" ])
      end
    end
  end
end
