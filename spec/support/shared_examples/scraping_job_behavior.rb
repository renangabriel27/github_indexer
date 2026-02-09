# frozen_string_literal: true

RSpec.shared_examples 'a scraping job' do |service_class, service_options|
  include_context 'Profile GitHub API stubs'
  include Dry::Monads::Result::Mixin

  let(:profile) { create(:profile, github_username: 'testuser') }

  describe '#perform' do
    context 'when profile exists and service succeeds' do
      before do
        allow(service_class).to receive(:call).and_return(Success({ profile: profile }))
      end

      it 'calls the service with correct parameters' do
        described_class.new.perform(profile.id)
        expect(service_class).to have_received(:call).with(profile, **service_options)
      end
    end

    context 'when service fails with retryable error' do
      before do
        allow(service_class).to receive(:call)
          .and_return(Failure(error: :timeout, message: "Timeout", retryable: true))
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:error)
      end

      it 'raises StandardError for retry' do
        expect { described_class.new.perform(profile.id) }.to raise_error(StandardError, "Timeout")
      end
    end

    context 'when service fails with non-retryable error' do
      before do
        allow(service_class).to receive(:call)
          .and_return(Failure(error: :not_found, message: "Not found", retryable: false))
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:error)
      end

      it 'does not raise error' do
        expect { described_class.new.perform(profile.id) }.not_to raise_error
      end
    end

    context 'when profile does not exist' do
      before { allow(Rails.logger).to receive(:warn) }

      it 'does not call service and does not raise error' do
        expect(service_class).not_to receive(:call)
        expect { described_class.new.perform(999_999) }.not_to raise_error
      end
    end
  end

  describe 'configuration' do
    it 'uses scraping queue with retry 3' do
      expect(described_class.new.queue_name).to eq('scraping')
      expect(described_class.sidekiq_options['retry']).to eq(3)
    end
  end

  describe 'sidekiq_retries_exhausted' do
    let(:exception) { StandardError.new("Browser timeout") }
    let(:job_hash) { { "args" => [ profile.id ] } }
    let(:broadcaster) { instance_double(Profiles::Github::Broadcaster) }

    before do
      allow(Profiles::Github::Broadcaster).to receive(:new).with(profile).and_return(broadcaster)
      allow(broadcaster).to receive(:broadcast_error)
    end

    it 'updates profile status to failed and broadcasts error' do
      described_class.sidekiq_retries_exhausted_block.call(job_hash, exception)

      profile.reload
      expect(profile.scraping_status).to eq('failed')
      expect(profile.last_error).to eq('Job failed after all retries')
      expect(broadcaster).to have_received(:broadcast_error)
    end
  end
end
