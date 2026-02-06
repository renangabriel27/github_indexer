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

    it 'calls Profiles::ScraperService with correct parameters' do
      described_class.new.perform(profile.id)

      expect(Profiles::ScraperService).to have_received(:call).with(profile, update_name: false)
    end

    it 'calls Profiles::ScraperService with update_name: true when specified' do
      described_class.new.perform(profile.id, update_name: true)

      expect(Profiles::ScraperService).to have_received(:call).with(profile, update_name: true)
    end

    it 'raises ActiveRecord::RecordNotFound when profile does not exist' do
      expect do
        described_class.new.perform(999_999)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

