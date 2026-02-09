# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Github::Extractors::StatisticsExtractor do
  let(:doc) { Nokogiri::HTML(html) }
  subject(:extractor) { described_class.new(doc) }

  describe "#call" do
    context "with valid statistics" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a href="/user?tab=followers"><span class="text-bold">185k</span> followers</a>
              <a href="/user?tab=following"><span class="text-bold">42</span> following</a>
              <a href="/user?tab=stars"><span class="text-bold">1.5k</span> stars</a>
              <h2 id="js-contribution-activity">4,123 contributions in the last year</h2>
            </body>
          </html>
        HTML
      end

      it "extracts all statistics correctly" do
        result = extractor.call.value!

        expect(result[:followers]).to eq(185_000)
        expect(result[:following]).to eq(42)
        expect(result[:stars]).to eq(1_500)
        expect(result[:contributions_last_year]).to eq(4_123)
      end
    end

    context "with missing elements" do
      let(:html) { "<html><body></body></html>" }

      it "returns 0 for all missing fields" do
        result = extractor.call.value!

        expect(result[:followers]).to eq(0)
        expect(result[:following]).to eq(0)
        expect(result[:stars]).to eq(0)
        expect(result[:contributions_last_year]).to eq(0)
      end
    end

    describe "number parsing" do
      let(:html) { "<html><body></body></html>" }

      {
        "42" => 42,
        "1,234" => 1234,
        "5k" => 5000,
        "2.5k" => 2500,
        "1.2M" => 1_200_000,
        "" => 0,
        nil => 0
      }.each do |input, expected|
        it "parses '#{input.inspect}' as #{expected}" do
          expect(extractor.send(:parse_number, input)).to eq(expected)
        end
      end
    end
  end
end
