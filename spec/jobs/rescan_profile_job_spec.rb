# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RescanProfileJob, type: :job do
  include_context 'Profile GitHub API stubs'

  describe '#perform' do
    context 'when profile can be rescanned' do
      let(:profile) { create(:profile, last_scanned_at: 10.minutes.ago, scraping_status: :completed) }

      it 'updates scraping_status and processes the profile' do
        initial_status = profile.scraping_status
        described_class.new.perform(profile.id)

        expect(profile.reload.scraping_status).not_to eq(initial_status)
        expect(profile.scraping_status).to be_in(%w[processing completed failed])
      end
    end

    context 'when profile cannot be rescanned' do
      let(:profile) do
        profile = create(:profile)
        profile.update_columns(
          last_scanned_at: 2.minutes.ago,
          scraping_status: 'completed'
        )
        profile.reload
      end

      it 'does not update scraping_status' do
        initial_status = profile.scraping_status
        described_class.new.perform(profile.id)
        expect(profile.reload.scraping_status).to eq(initial_status)
      end
    end

    context 'when profile has never been scanned' do
      let(:profile) { create(:profile, last_scanned_at: nil, scraping_status: :pending) }

      it 'processes the profile' do
        initial_status = profile.scraping_status
        described_class.new.perform(profile.id)

        expect(profile.reload.scraping_status).not_to eq(initial_status)
        expect(profile.scraping_status).to be_in(%w[processing completed failed])
      end
    end

    it 'raises ActiveRecord::RecordNotFound when profile does not exist' do
      expect do
        described_class.new.perform(999_999)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

