# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profiles::RescanService do
  include Dry::Monads::Result::Mixin

  describe "#call" do
    let(:profile) { create(:profile) }

    context "when profile can be rescanned" do
      context "when never scanned before" do
        before { profile.update!(last_scanned_at: nil) }

        it "returns Success" do
          allow(Profiles::ScraperService).to receive(:call).and_return(Success({ data: "test" }))

          result = described_class.call(profile)

          expect(result).to be_success
        end

        it "delegates to ScraperService with update_name: true" do
          allow(Profiles::ScraperService).to receive(:call).and_return(Success({ data: "test" }))

          described_class.call(profile)

          expect(Profiles::ScraperService).to have_received(:call).with(profile, update_name: true)
        end
      end

      context "when scanned more than 5 minutes ago" do
        before { profile.update!(last_scanned_at: 6.minutes.ago) }

        it "returns Success" do
          allow(Profiles::ScraperService).to receive(:call).and_return(Success({ data: "test" }))

          result = described_class.call(profile)

          expect(result).to be_success
        end

        it "delegates to ScraperService" do
          allow(Profiles::ScraperService).to receive(:call).and_return(Success({ data: "test" }))

          described_class.call(profile)

          expect(Profiles::ScraperService).to have_received(:call).with(profile, update_name: true)
        end
      end
    end

    context "when profile cannot be rescanned (too soon)" do
      before { profile.update!(last_scanned_at: 2.minutes.ago) }

      it "returns Failure" do
        result = described_class.call(profile)

        expect(result).to be_failure
      end

      it "returns error :rescan_too_soon" do
        result = described_class.call(profile)

        expect(result.failure[:error]).to eq(:rescan_too_soon)
      end

      it "includes informative message with time since scan" do
        result = described_class.call(profile)

        expect(result.failure[:message]).to match(/Profile scanned .* ago/)
      end

      it "includes time until eligible in message" do
        result = described_class.call(profile)

        expect(result.failure[:message]).to match(/Wait .*/)
      end

      it "marks error as non-retryable" do
        result = described_class.call(profile)

        expect(result.failure[:retryable]).to eq(false)
      end

      it "does not call ScraperService" do
        expect(Profiles::ScraperService).not_to receive(:call)

        described_class.call(profile)
      end
    end

    context "when ScraperService fails" do
      before { profile.update!(last_scanned_at: nil) }

      it "returns the failure from ScraperService" do
        failure_result = Failure(error: :timeout, message: "Timeout", retryable: true)
        allow(Profiles::ScraperService).to receive(:call).and_return(failure_result)

        result = described_class.call(profile)

        expect(result).to be_failure
        expect(result.failure[:error]).to eq(:timeout)
      end
    end

    describe "time formatting" do
      context "when scanned 30 seconds ago" do
        before { profile.update!(last_scanned_at: 30.seconds.ago) }

        it "shows seconds in message" do
          result = described_class.call(profile)

          expect(result.failure[:message]).to match(/\d+ seconds/)
        end
      end

      context "when scanned 1 minute ago" do
        before { profile.update!(last_scanned_at: 1.minute.ago) }

        it "shows singular minute in message" do
          result = described_class.call(profile)

          expect(result.failure[:message]).to match(/1 minute ago/)
        end
      end

      context "when scanned 3 minutes ago" do
        before { profile.update!(last_scanned_at: 3.minutes.ago) }

        it "shows plural minutes in message" do
          result = described_class.call(profile)

          expect(result.failure[:message]).to match(/3 minutes ago/)
        end
      end

      context "when never scanned" do
        before { profile.update!(last_scanned_at: nil) }

        it "shows 'never' in message when eligible (though this won't fail)" do
          # This is more of a documentation test showing the behavior
          # The actual call will succeed, but we're testing the private method logic
          service = described_class.new(profile)
          expect(service.send(:time_since_scan)).to eq("never")
        end
      end
    end
  end
end
