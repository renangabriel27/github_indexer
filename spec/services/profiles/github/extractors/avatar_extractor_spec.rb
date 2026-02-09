# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Github::Extractors::AvatarExtractor do
  let(:doc) { Nokogiri::HTML(html) }
  subject(:extractor) { described_class.new(doc) }

  describe "#call" do
    context "with avatar from img tag" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <img class="avatar-user" src="https://avatars.githubusercontent.com/u/1024025?s=64&v=4">
            </body>
          </html>
        HTML
      end

      it "returns Success monad" do
        expect(extractor.call).to be_success
      end

      it "extracts avatar URL" do
        result = extractor.call.value!
        expect(result[:avatar_url]).to eq("https://avatars.githubusercontent.com/u/1024025?v=4")
      end

      it "removes s=64& parameter" do
        result = extractor.call.value!
        expect(result[:avatar_url]).not_to include("s=64&")
      end
    end

    context "with avatar from meta tag" do
      let(:html) do
        <<~HTML
          <html>
            <head>
              <meta property="og:image" content="https://avatars.githubusercontent.com/u/1024025?v=4">
            </head>
          </html>
        HTML
      end

      it "extracts avatar from meta tag" do
        result = extractor.call.value!
        expect(result[:avatar_url]).to eq("https://avatars.githubusercontent.com/u/1024025?v=4")
      end
    end

    context "with protocol-relative URL" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <img class="avatar-user" src="//avatars.githubusercontent.com/u/123?s=64&v=4">
            </body>
          </html>
        HTML
      end

      it "adds https: protocol" do
        result = extractor.call.value!
        expect(result[:avatar_url]).to start_with("https://")
        expect(result[:avatar_url]).to eq("https://avatars.githubusercontent.com/u/123?v=4")
      end
    end

    context "with relative URL" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <img class="avatar-user" src="/avatars/user123.png">
            </body>
          </html>
        HTML
      end

      it "prepends github.com domain" do
        result = extractor.call.value!
        expect(result[:avatar_url]).to eq("https://github.com/avatars/user123.png")
      end
    end

    context "with missing avatar" do
      let(:html) { "<html><body></body></html>" }

      it "returns nil" do
        result = extractor.call.value!
        expect(result[:avatar_url]).to be_nil
      end

      describe "#normalize_url" do
        it "returns nil for blank URLs" do
          expect(extractor.send(:normalize_url, nil)).to be_nil
          expect(extractor.send(:normalize_url, "")).to be_nil
        end

        it "returns URL unchanged if it starts with http" do
          url = "http://example.com/image.png"
          expect(extractor.send(:normalize_url, url)).to eq(url)
        end

        it "returns URL unchanged if it starts with https" do
          url = "https://example.com/image.png"
          expect(extractor.send(:normalize_url, url)).to eq(url)
        end

        it "adds https: for protocol-relative URLs" do
          expect(extractor.send(:normalize_url, "//example.com/image.png")).to eq("https://example.com/image.png")
        end

        it "adds github.com domain for relative URLs" do
          expect(extractor.send(:normalize_url, "/path/to/image.png")).to eq("https://github.com/path/to/image.png")
        end
      end
    end
  end
end
