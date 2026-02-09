# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Github::Extractors::LocationExtractor do
  let(:doc) { Nokogiri::HTML(html) }
  subject(:extractor) { described_class.new(doc) }

  describe "#call" do
    context "with valid location" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <div itemprop="homeLocation">
                <span class="p-label">Portland, OR</span>
              </div>
            </body>
          </html>
        HTML
      end

      it "returns Success monad" do
        expect(extractor.call).to be_success
      end

      it "extracts location" do
        result = extractor.call.value!
        expect(result[:location]).to eq("Portland, OR")
      end
    end

    context "with whitespace in location" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <div itemprop="homeLocation">
                <span class="p-label">  San Francisco, CA  </span>
              </div>
            </body>
          </html>
        HTML
      end

      it "strips whitespace" do
        result = extractor.call.value!
        expect(result[:location]).to eq("San Francisco, CA")
      end
    end

    context "with missing location" do
      let(:html) { "<html><body></body></html>" }

      it "returns nil" do
        result = extractor.call.value!
        expect(result[:location]).to be_nil
      end
    end

    context "with location container but no label" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <div itemprop="homeLocation">
              </div>
            </body>
          </html>
        HTML
      end

      it "returns nil" do
        result = extractor.call.value!
        expect(result[:location]).to be_nil
      end
    end
  end
end
