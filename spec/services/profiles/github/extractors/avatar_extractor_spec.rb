# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::Github::Extractors::AvatarExtractor do
  let(:doc) { Nokogiri::HTML(html) }
  subject(:extractor) { described_class.new(doc) }

  describe "#call" do
    context "with avatar from img tag" do
      let(:html) do
        <<~HTML
          <html><body>
            <img class="avatar-user" src="https://avatars.githubusercontent.com/u/1024025?s=64&v=4">
          </body></html>
        HTML
      end

      it "extracts avatar URL and removes size parameter" do
        result = extractor.call.value!
        expect(result[:avatar_url]).to eq("https://avatars.githubusercontent.com/u/1024025?v=4")
      end
    end

    context "with protocol-relative URL" do
      let(:html) { '<html><body><img class="avatar-user" src="//avatars.githubusercontent.com/u/123?v=4"></body></html>' }

      it "adds https: protocol" do
        expect(extractor.call.value![:avatar_url]).to start_with("https://")
      end
    end

    context "with relative URL" do
      let(:html) { '<html><body><img class="avatar-user" src="/avatars/user123.png"></body></html>' }

      it "prepends github.com domain" do
        expect(extractor.call.value![:avatar_url]).to eq("https://github.com/avatars/user123.png")
      end
    end

    context "with missing avatar" do
      let(:html) { "<html><body></body></html>" }

      it "returns nil" do
        expect(extractor.call.value![:avatar_url]).to be_nil
      end
    end
  end
end
