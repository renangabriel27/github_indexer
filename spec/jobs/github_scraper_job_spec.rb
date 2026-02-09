# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubScraperJob, type: :job do
  it_behaves_like 'a scraping job', Profiles::Github::ScraperService, { update_name: false }

  describe 'update_name parameter' do
    include_context 'Profile GitHub API stubs'
    include Dry::Monads::Result::Mixin

    let(:profile) { create(:profile, github_username: 'testuser') }

    before do
      allow(Profiles::Github::ScraperService).to receive(:call).and_return(Success({ profile: profile }))
    end

    it 'passes update_name: true when specified' do
      described_class.new.perform(profile.id, update_name: true)
      expect(Profiles::Github::ScraperService).to have_received(:call).with(profile, update_name: true)
    end
  end

  describe 'retry strategy' do
    let(:job) { described_class.new }

    {
      [ 1, Ferrum::TimeoutError.new("timeout") ] => 60,
      [ 2, Ferrum::TimeoutError.new("timeout") ] => 180,
      [ 1, Net::OpenTimeout.new("timeout") ] => 30,
      [ 1, StandardError.new("error") ] => 10
    }.each do |(retry_count, exception), expected_delay|
      it "returns #{expected_delay}s for #{exception.class} on retry #{retry_count}" do
        expect(job.sidekiq_retry_in_block.call(retry_count, exception)).to eq(expected_delay)
      end
    end

    it 'returns :kill for unknown exception types' do
      unknown_error = Class.new(Exception).new("unknown")
      expect(job.sidekiq_retry_in_block.call(1, unknown_error)).to eq(:kill)
    end
  end
end
