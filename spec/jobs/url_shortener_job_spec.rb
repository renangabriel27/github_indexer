# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlShortenerJob, type: :job do
  include_context 'Profile GitHub API stubs'

  describe '#perform' do
    let(:profile) { create(:profile, github_username: 'testuser') }
    let(:expected_github_url) { "https://github.com/#{profile.github_username}" }
    let(:short_url) { 'https://go.short.io/abc123' }
    let(:service_instance) { instance_double(ShortioUrlShortenerService) }

    before do
      allow(ShortioUrlShortenerService).to receive(:new).with(expected_github_url).and_return(service_instance)
    end

    context 'when service returns a short URL successfully' do
      before do
        allow(service_instance).to receive(:call).and_return({ short_url: short_url })
      end

      it 'updates the profile with the short URL' do
        expect do
          described_class.new.perform(profile.id)
        end.to change { profile.reload.short_github_url }.to(short_url)
      end

      it 'calls ShortioUrlShortenerService with the correct GitHub URL' do
        described_class.new.perform(profile.id)

        expect(ShortioUrlShortenerService).to have_received(:new).with(expected_github_url)
        expect(service_instance).to have_received(:call)
      end

      it 'logs the job execution' do
        expect(Rails.logger).to receive(:info).with("=== UrlShortenerJob iniciado para profile_id: #{profile.id} ===")

        described_class.new.perform(profile.id)
      end
    end

    context 'when service returns an error' do
      before do
        allow(service_instance).to receive(:call).and_return({ success: false, error: 'API Error' })
      end

      it 'updates the profile with nil short_url' do
        described_class.new.perform(profile.id)

        expect(profile.reload.short_github_url).to be_nil
      end
    end

    context 'when service returns nil short_url' do
      before do
        allow(service_instance).to receive(:call).and_return({ short_url: nil })
      end

      it 'updates the profile with nil' do
        described_class.new.perform(profile.id)

        expect(profile.reload.short_github_url).to be_nil
      end
    end

    context 'when profile does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          described_class.new.perform(999_999)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when service raises an exception' do
      before do
        allow(service_instance).to receive(:call).and_raise(StandardError, 'Service error')
      end

      it 'raises the exception' do
        expect do
          described_class.new.perform(profile.id)
        end.to raise_error(StandardError, 'Service error')
      end

      it 'does not update the profile' do
        original_url = profile.short_github_url

        begin
          described_class.new.perform(profile.id)
        rescue StandardError
        end

        expect(profile.reload.short_github_url).to eq(original_url)
      end
    end
  end
end

