require 'rails_helper'

RSpec.describe Profiles::ScraperService, '#call - error scenarios' do
  include_context 'Ferrum browser setup'
  include_context 'GitHub HTML fixtures'
  include_context 'Profile GitHub API stubs'

  let(:profile) { create(:profile, github_username: 'notfound') }
  let(:service) { described_class.new(profile) }

  describe 'profile not found' do
    before do
      allow(browser_mock).to receive(:body).and_return(github_404_html)
      allow(browser_mock).to receive(:go_to)
      allow(browser_mock).to receive(:at_css).with('h2[id*="contribution"]').and_return(false)
      allow(browser_mock).to receive(:at_css).with('title').and_return(
        double(text: 'Page not found · GitHub')
      )
      allow(browser_mock).to receive(:quit)
    end

    it 'returns Failure with error message' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure[:error]).to eq(:profile_not_found)
      expect(result.failure[:message]).to include('Perfil não encontrado')
    end

    it 'updates status to failed' do
      service.call
      profile.reload

      expect(profile.scraping_status).to eq('failed')
    end

    it 'closes the browser' do
      expect(browser_mock).to receive(:quit)
      service.call
    end
  end

  describe 'generic errors' do
    before do
      allow(browser_mock).to receive(:go_to).and_raise(StandardError, 'Connection error')
      allow(browser_mock).to receive(:quit)
    end

    it 'returns Failure and updates status to failed' do
      result = service.call

      expect(result).to be_failure
      expect(profile.reload.scraping_status).to eq('failed')
    end

    it 'closes the browser even on error' do
      expect(browser_mock).to receive(:quit)
      service.call
    end
  end
end
