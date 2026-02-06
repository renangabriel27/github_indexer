# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubScraperJob, type: :job do
  include_context 'Profile GitHub API stubs'

  describe '#perform' do
    let(:profile) { create(:profile, github_username: 'testuser') }
    let(:service_result) { instance_double(Dry::Monads::Result::Success, success?: true) }

    before do
      allow(Profiles::ScraperService).to receive(:call).and_return(service_result)
    end

    context 'when service returns success' do
      it 'calls Profiles::ScraperService with correct parameters' do
        described_class.new.perform(profile.id)

        expect(Profiles::ScraperService).to have_received(:call).with(profile, update_name: false)
      end

      it 'calls Profiles::ScraperService with update_name: true when specified' do
        described_class.new.perform(profile.id, update_name: true)

        expect(Profiles::ScraperService).to have_received(:call).with(profile, update_name: true)
      end

      it 'logs the job execution' do
        expect(Rails.logger).to receive(:info).with("=== GithubScraperJob iniciado para profile_id: #{profile.id} ===")

        described_class.new.perform(profile.id)
      end

      it 'returns nil when result is successful' do
        result = described_class.new.perform(profile.id)

        expect(result).to be_nil
      end
    end

    context 'when service returns failure' do
      let(:service_result) { instance_double(Dry::Monads::Result::Failure, success?: false) }

      it 'calls Profiles::ScraperService with correct parameters' do
        described_class.new.perform(profile.id)

        expect(Profiles::ScraperService).to have_received(:call).with(profile, update_name: false)
      end

      it 'returns nil when result is not successful' do
        result = described_class.new.perform(profile.id)

        expect(result).to be_nil
      end

      it 'logs the job execution even on failure' do
        expect(Rails.logger).to receive(:info).with("=== GithubScraperJob iniciado para profile_id: #{profile.id} ===")

        described_class.new.perform(profile.id)
      end
    end

    context 'when profile does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          described_class.new.perform(999_999)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not call Profiles::ScraperService when profile is not found' do
        begin
          described_class.new.perform(999_999)
        rescue ActiveRecord::RecordNotFound
        end

        expect(Profiles::ScraperService).not_to have_received(:call)
      end
    end

    context 'when service raises an exception' do
      before do
        allow(Profiles::ScraperService).to receive(:call).and_raise(StandardError, 'Service error')
      end

      it 'raises the exception' do
        expect do
          described_class.new.perform(profile.id)
        end.to raise_error(StandardError, 'Service error')
      end

      it 'logs the job execution before the exception' do
        expect(Rails.logger).to receive(:info).with("=== GithubScraperJob iniciado para profile_id: #{profile.id} ===")

        begin
          described_class.new.perform(profile.id)
        rescue StandardError
        end
      end
    end
  end
end

