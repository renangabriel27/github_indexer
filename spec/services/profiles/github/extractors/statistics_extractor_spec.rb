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
              <a href="/user?tab=followers">
                <span class="text-bold">185k</span> followers
              </a>
              <a href="/user?tab=following">
                <span class="text-bold">42</span> following
              </a>
              <a href="/user?tab=stars">
                <span class="text-bold">1.5k</span> stars
              </a>
              <h2 id="js-contribution-activity">4,123 contributions in the last year</h2>
            </body>
          </html>
        HTML
      end

      it "returns Success monad" do
        expect(extractor.call).to be_success
      end

      it "extracts followers with k multiplier" do
        result = extractor.call.value!
        expect(result[:followers]).to eq(185_000)
      end

      it "extracts following as plain number" do
        result = extractor.call.value!
        expect(result[:following]).to eq(42)
      end

      it "extracts stars with decimal k multiplier" do
        result = extractor.call.value!
        expect(result[:stars]).to eq(1_500)
      end

      it "extracts contributions removing commas" do
        result = extractor.call.value!
        expect(result[:contributions_last_year]).to eq(4123)
      end
    end

    context "with M multiplier" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a href="/user?tab=followers">
                <span class="text-bold">2.5M</span> followers
              </a>
            </body>
          </html>
        HTML
      end

      it "parses millions correctly" do
        result = extractor.call.value!
        expect(result[:followers]).to eq(2_500_000)
      end
    end

    context "with Counter component selector" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a href="/user?tab=followers">
                <span data-view-component="true" class="Counter">250</span> followers
              </a>
            </body>
          </html>
        HTML
      end

      it "extracts from Counter component" do
        result = extractor.call.value!
        expect(result[:followers]).to eq(250)
      end
    end

    context "with fallback to link text scanning" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <a href="/user?tab=followers">123 followers</a>
            </body>
          </html>
        HTML
      end

      it "scans link text for numbers" do
        result = extractor.call.value!
        expect(result[:followers]).to eq(123)
      end
    end

    context "with missing elements" do
      let(:html) { "<html><body></body></html>" }

      it "returns 0 for missing followers" do
        result = extractor.call.value!
        expect(result[:followers]).to eq(0)
      end

      it "returns 0 for missing following" do
        result = extractor.call.value!
        expect(result[:following]).to eq(0)
      end

      it "returns 0 for missing stars" do
        result = extractor.call.value!
        expect(result[:stars]).to eq(0)
      end

      it "returns 0 for missing contributions" do
        result = extractor.call.value!
        expect(result[:contributions_last_year]).to eq(0)
      end
    end

    context "with contributions variations" do
      context "with alternative contribution selector" do
        let(:html) do
          <<~HTML
            <html>
              <body>
                <h2 id="contribution-activity">987 contributions in the last year</h2>
              </body>
            </html>
          HTML
        end

        it "extracts contributions from alternative selector" do
          result = extractor.call.value!
          expect(result[:contributions_last_year]).to eq(987)
        end
      end

      context "with no number in contributions text" do
        let(:html) do
          <<~HTML
            <html>
              <body>
                <h2 id="js-contribution-activity">No contributions yet</h2>
              </body>
            </html>
          HTML
        end

        it "returns 0 when no number found" do
          result = extractor.call.value!
          expect(result[:contributions_last_year]).to eq(0)
        end
      end

      context "with period separator in contributions" do
        let(:html) do
          <<~HTML
            <html>
              <body>
                <h2 id="js-contribution-activity">1.234 contributions in the last year</h2>
              </body>
            </html>
          HTML
        end

        it "removes periods from contributions" do
          result = extractor.call.value!
          expect(result[:contributions_last_year]).to eq(1234)
        end
      end
    end

    context "with missing elements" do
      let(:html) { "<html><body></body></html>" }

      describe "#parse_number" do
        it "parses plain numbers" do
          expect(extractor.send(:parse_number, "42")).to eq(42)
        end

        it "parses numbers with commas" do
          expect(extractor.send(:parse_number, "1,234")).to eq(1234)
        end

        it "parses numbers with spaces" do
          expect(extractor.send(:parse_number, "1 234")).to eq(1234)
        end

        it "parses k multiplier (lowercase)" do
          expect(extractor.send(:parse_number, "5k")).to eq(5000)
        end

        it "parses k multiplier (uppercase)" do
          expect(extractor.send(:parse_number, "5K")).to eq(5000)
        end

        it "parses decimal with k multiplier" do
          expect(extractor.send(:parse_number, "2.5k")).to eq(2500)
        end

        it "parses M multiplier" do
          expect(extractor.send(:parse_number, "1.2M")).to eq(1_200_000)
        end

        it "returns 0 for blank text" do
          expect(extractor.send(:parse_number, "")).to eq(0)
          expect(extractor.send(:parse_number, nil)).to eq(0)
        end
      end
    end
  end
end
