# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Github::Extractors::LocationExtractor do
  let(:doc) { Nokogiri::HTML(html) }
  subject(:extractor) { described_class.new(doc) }

  describe "#call" do
    context "with valid location" do
      let(:html) do
        <<~HTML
          <html><body>
            <div itemprop="homeLocation"><span class="p-label">  Portland, OR  </span></div>
          </body></html>
        HTML
      end

      it "extracts and strips location" do
        expect(extractor.call.value![:location]).to eq("Portland, OR")
      end
    end

    context "with missing location" do
      let(:html) { "<html><body></body></html>" }

      it "returns nil" do
        expect(extractor.call.value![:location]).to be_nil
      end
    end
  end
end
