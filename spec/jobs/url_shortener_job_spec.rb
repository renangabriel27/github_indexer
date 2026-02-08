# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlShortenerJob, type: :job do
  include_context 'Profile GitHub API stubs'

  describe '#perform' do
    let(:profile) { create(:profile, github_username: 'testuser', short_github_url: nil) }
    let(:expected_github_url) { "https://github.com/#{profile.github_username}" }
    let(:short_url) { 'https://go.short.io/abc123' }

    context 'when profile exists' do
      context 'when service returns success' do
        before do
          allow(UrlShortenerService).to receive(:call)
            .with(expected_github_url)
            .and_return(Dry::Monads::Success(short_url: short_url, original_url: expected_github_url))
        end

        it 'updates the profile with the short URL' do
          expect do
            described_class.new.perform(profile.id)
          end.to change { profile.reload.short_github_url }.to(short_url)
        end

        it 'calls UrlShortenerService with the correct GitHub URL' do
          described_class.new.perform(profile.id)

          expect(UrlShortenerService).to have_received(:call).with(expected_github_url)
        end
      end

      context 'when service returns a retryable error' do
        before do
          allow(UrlShortenerService).to receive(:call)
            .and_return(Dry::Monads::Failure(error: :timeout, message: 'Request timeout', retryable: true))
        end

        it 'raises StandardError to trigger retry' do
          expect do
            described_class.new.perform(profile.id)
          end.to raise_error(StandardError, 'Request timeout')
        end

        it 'does not update the profile' do
          expect do
            described_class.new.perform(profile.id) rescue nil
          end.not_to change { profile.reload.short_github_url }
        end
      end

      context 'when service returns a non-retryable error' do
        before do
          allow(UrlShortenerService).to receive(:call)
            .and_return(Dry::Monads::Failure(error: :authentication_failed, message: 'Invalid API Key', retryable: false))
        end

        it 'does not raise an error' do
          expect do
            described_class.new.perform(profile.id)
          end.not_to raise_error
        end

        it 'does not update the profile' do
          expect do
            described_class.new.perform(profile.id)
          end.not_to change { profile.reload.short_github_url }
        end
      end
    end

    context 'when profile does not exist' do
      it 'does not raise an error' do
        expect do
          described_class.new.perform(999_999)
        end.not_to raise_error
      end

      it 'logs a warning' do
        expect(Rails.logger).to receive(:warn).with(/Profile#999999 not found/)
        described_class.new.perform(999_999)
      end

      it 'does not call the service' do
        expect(UrlShortenerService).not_to receive(:call)
        described_class.new.perform(999_999)
      end
    end
  end
end
