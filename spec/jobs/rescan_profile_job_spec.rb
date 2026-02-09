# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RescanProfileJob, type: :job do
  include_context 'Profile GitHub API stubs'
  include Dry::Monads::Result::Mixin

  describe '#perform' do
    let(:profile) { create(:profile, github_username: 'testuser') }

    context 'when profile exists' do
      context 'when rescan is successful' do
        let(:service_result) { Success({ profile: profile, data: "rescanned_data" }) }

        before do
          profile.update!(last_scanned_at: 10.minutes.ago)
          allow(Profiles::RescanService).to receive(:call).and_return(service_result)
        end

        it 'calls Profiles::RescanService' do
          described_class.new.perform(profile.id)

          expect(Profiles::RescanService).to have_received(:call).with(profile)
        end

        it 'logs started event' do
          allow(Rails.logger).to receive(:info).and_call_original
          expect(Rails.logger).to receive(:info).with(/\[RescanProfileJob\].*started.*profile_id=#{profile.id}/).and_call_original
          described_class.new.perform(profile.id)
        end

        it 'logs success event' do
          allow(Rails.logger).to receive(:info).and_call_original
          expect(Rails.logger).to receive(:info).with(/\[RescanProfileJob\].*success.*profile_id=#{profile.id}/).and_call_original
          described_class.new.perform(profile.id)
        end
      end

      context 'when rescan fails due to too soon' do
        let(:service_result) do
          Failure(
            error: :rescan_too_soon,
            message: "Profile scanned 2 minutes ago. Wait 3 minutes.",
            retryable: false
          )
        end

        before do
          profile.update!(last_scanned_at: 2.minutes.ago)
          allow(Profiles::RescanService).to receive(:call).and_return(service_result)
        end

        it 'logs failed event' do
          expect(Rails.logger).to receive(:error).with(/failed.*profile_id=#{profile.id}.*rescan_too_soon/)
          described_class.new.perform(profile.id)
        end

        it 'does not raise error (non-retryable)' do
          allow(Rails.logger).to receive(:info)
          allow(Rails.logger).to receive(:error)

          expect do
            described_class.new.perform(profile.id)
          end.not_to raise_error
        end
      end

      context 'when rescan fails with retryable error' do
        let(:service_result) do
          Failure(
            error: :timeout,
            message: "Browser timeout",
            retryable: true
          )
        end

        before do
          profile.update!(last_scanned_at: 10.minutes.ago)
          allow(Profiles::RescanService).to receive(:call).and_return(service_result)
        end

        it 'logs failed event' do
          expect(Rails.logger).to receive(:info).with(/started/)
          expect(Rails.logger).to receive(:error).with(/\[RescanProfileJob\].*failed.*profile_id=#{profile.id}/)

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
    end

    context 'when profile does not exist' do
      it 'logs warning and does not raise error' do
        expect(Rails.logger).to receive(:warn).with(/\[RescanProfileJob\].*not_found.*id=999999/)

        expect do
          described_class.new.perform(999_999)
        end.not_to raise_error
      end

      it 'does not call service' do
        allow(Rails.logger).to receive(:warn)

        expect(Profiles::RescanService).not_to receive(:call)
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

    it 'returns :kill for unknown exception types' do
      unknown_error = Class.new(Exception).new("unknown error")
      delay = job.sidekiq_retry_in_block.call(1, unknown_error)
      expect(delay).to eq(:kill)
    end
  end

  describe 'sidekiq_retries_exhausted' do
    let(:profile) { create(:profile, github_username: 'testuser') }
    let(:exception) { StandardError.new("Browser timeout") }
    let(:job_hash) { { "args" => [ profile.id ] } }
    let(:broadcaster) { instance_double(Profiles::Github::Broadcaster) }

    before do
      allow(Profiles::Github::Broadcaster).to receive(:new).with(profile).and_return(broadcaster)
      allow(broadcaster).to receive(:broadcast_error)
    end

    it 'updates profile status to failed' do
      described_class.sidekiq_retries_exhausted_block.call(job_hash, exception)

      expect(profile.reload.scraping_status).to eq('failed')
    end

    it 'sets last_error message' do
      described_class.sidekiq_retries_exhausted_block.call(job_hash, exception)

      expect(profile.reload.last_error).to eq('Job failed after all retries')
    end

    it 'updates last_scanned_at timestamp' do
      expect do
        described_class.sidekiq_retries_exhausted_block.call(job_hash, exception)
      end.to change { profile.reload.last_scanned_at }

      expect(profile.last_scanned_at).to be_within(1.second).of(Time.current)
    end

    it 'broadcasts error message' do
      described_class.sidekiq_retries_exhausted_block.call(job_hash, exception)

      expect(broadcaster).to have_received(:broadcast_error).with('Erro ao processar perfil após múltiplas tentativas')
    end

    context 'when profile does not exist' do
      let(:job_hash) { { "args" => [ 999_999 ] } }

      it 'does not raise error' do
        expect do
          described_class.sidekiq_retries_exhausted_block.call(job_hash, exception)
        end.not_to raise_error
      end

      it 'does not attempt to broadcast' do
        described_class.sidekiq_retries_exhausted_block.call(job_hash, exception)

        expect(Profiles::Github::Broadcaster).not_to have_received(:new)
      end
    end
  end
end
