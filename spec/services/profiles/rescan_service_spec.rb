# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::RescanService do
  include Dry::Monads::Result::Mixin

  describe "#call" do
    let(:profile) { create(:profile) }

    context "when profile can be rescanned" do
      before do
        profile.update!(last_scanned_at: nil)
        allow(Profiles::Github::ScraperService).to receive(:call).and_return(Success({ data: "test" }))
      end

      it "returns Success and delegates to ScraperService" do
        result = described_class.call(profile)

        expect(result).to be_success
        expect(Profiles::Github::ScraperService).to have_received(:call).with(profile, update_name: true)
      end

      it "allows rescan when last scan was more than 5 minutes ago" do
        profile.update!(last_scanned_at: 6.minutes.ago)

        result = described_class.call(profile)

        expect(result).to be_success
      end
    end

    context "when profile cannot be rescanned (too soon)" do
      before { profile.update!(last_scanned_at: 2.minutes.ago) }

      it "returns Failure with appropriate error details" do
        result = described_class.call(profile)

        expect(result).to be_failure
        expect(result.failure[:error]).to eq(:rescan_too_soon)
        expect(result.failure[:message]).to match(/Profile scanned .* ago.*Wait/)
        expect(result.failure[:retryable]).to eq(false)
      end

      it "does not call ScraperService" do
        expect(Profiles::Github::ScraperService).not_to receive(:call)
        described_class.call(profile)
      end
    end

    context "when ScraperService fails" do
      before { profile.update!(last_scanned_at: nil) }

      it "returns the failure from ScraperService" do
        allow(Profiles::Github::ScraperService).to receive(:call)
          .and_return(Failure(error: :timeout, message: "Timeout", retryable: true))

        result = described_class.call(profile)

        expect(result).to be_failure
        expect(result.failure[:error]).to eq(:timeout)
      end
    end
  end
end
