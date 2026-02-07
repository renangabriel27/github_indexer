# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubScraperJob, type: :job do
  include_context 'Profile GitHub API stubs'
  include Dry::Monads::Result::Mixin

  describe '#perform' do
    let(:profile) { create(:profile, github_username: 'testuser') }

    context 'when profile exists' do
      context 'when scraping is successful' do
        let(:service_result) { Success({ profile: profile, data: "scraped_data" }) }

        before do
          allow(Profiles::ScraperService).to receive(:call).and_return(service_result)
        end

        it 'calls Profiles::ScraperService with correct parameters' do
          described_class.new.perform(profile.id)

          expect(Profiles::ScraperService).to have_received(:call).with(profile, update_name: false)
        end

        it 'calls Profiles::ScraperService with update_name: true when specified' do
          described_class.new.perform(profile.id, update_name: true)

          expect(Profiles::ScraperService).to have_received(:call).with(profile, update_name: true)
        end

        it 'logs started event' do
          allow(Rails.logger).to receive(:info).and_call_original
          expect(Rails.logger).to receive(:info).with(/\[GithubScraperJob\].*started.*profile_id=#{profile.id}/).and_call_original
          described_class.new.perform(profile.id)
        end

        it 'logs success event' do
          allow(Rails.logger).to receive(:info).and_call_original
          expect(Rails.logger).to receive(:info).with(/\[GithubScraperJob\].*success.*profile_id=#{profile.id}/).and_call_original
          described_class.new.perform(profile.id)
        end
      end

      context 'when scraping fails with retryable error' do
        let(:service_result) do
          Failure(
            error: :timeout,
            message: "Browser timeout",
            retryable: true
          )
        end

        before do
          allow(Profiles::ScraperService).to receive(:call).and_return(service_result)
        end

        it 'logs failed event' do
          expect(Rails.logger).to receive(:info).with(/started/)
          expect(Rails.logger).to receive(:error).with(/\[GithubScraperJob\].*failed.*profile_id=#{profile.id}/)

          expect do
            described_class.new.perform(profile.id)
          end.to raise_error(StandardError)
        end

        it 'raises StandardError for retry' do
          allow(Rails.logger).to receive(:info)
          allow(Rails.logger).to receive(:error)

          expect do
            described_class.new.perform(profile.id)
          end.to raise_error(StandardError, "Browser timeout")
        end
      end

      context 'when scraping fails with non-retryable error' do
        let(:service_result) do
          Failure(
            error: :profile_not_found,
            message: "Profile not found on GitHub",
            retryable: false
          )
        end

        before do
          allow(Profiles::ScraperService).to receive(:call).and_return(service_result)
        end

        it 'logs failed event' do
          expect(Rails.logger).to receive(:error).with(/failed.*profile_id=#{profile.id}/)
          described_class.new.perform(profile.id)
        end

        it 'does not raise error (job completes)' do
          allow(Rails.logger).to receive(:info)
          allow(Rails.logger).to receive(:error)

          expect do
            described_class.new.perform(profile.id)
          end.not_to raise_error
        end
      end
    end

    context 'when profile does not exist' do
      it 'logs warning and does not raise error' do
        expect(Rails.logger).to receive(:warn).with(/\[GithubScraperJob\].*not_found.*id=999999/)

        expect do
          described_class.new.perform(999_999)
        end.not_to raise_error
      end

      it 'does not call service' do
        allow(Rails.logger).to receive(:warn)

        expect(Profiles::ScraperService).not_to receive(:call)
        described_class.new.perform(999_999)
      end
    end
  end

  describe 'configuration' do
    it 'uses scraping queue' do
      expect(described_class.new.queue_name).to eq('scraping')
    end

    it 'has retry configured' do
      expect(described_class.sidekiq_options['retry']).to eq(3)
    end

    it 'has dead queue enabled' do
      expect(described_class.sidekiq_options['dead']).to eq(true)
    end

    it 'has backtrace enabled' do
      expect(described_class.sidekiq_options['backtrace']).to eq(20)
    end
  end

  describe 'retry strategy' do
    let(:job) { described_class.new }

    it 'returns 60 seconds for Ferrum::TimeoutError on first retry' do
      delay = job.sidekiq_retry_in_block.call(1, Ferrum::TimeoutError.new("timeout"))
      expect(delay).to eq(60)
    end

    it 'returns 180 seconds for Ferrum::TimeoutError on second retry' do
      delay = job.sidekiq_retry_in_block.call(2, Ferrum::TimeoutError.new("timeout"))
      expect(delay).to eq(180)
    end

    it 'returns 30 seconds for Net::OpenTimeout on first retry' do
      delay = job.sidekiq_retry_in_block.call(1, Net::OpenTimeout.new("timeout"))
      expect(delay).to eq(30)
    end

    it 'returns 10 seconds for StandardError on first retry' do
      delay = job.sidekiq_retry_in_block.call(1, StandardError.new("generic error"))
      expect(delay).to eq(10)
    end
  end
end
