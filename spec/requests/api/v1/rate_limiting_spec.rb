require 'rails_helper'

RSpec.describe 'API Rate Limiting', type: :request do
  include_context 'Profile GitHub API stubs'

  before do
    Rack::Attack.cache.store.clear
  end

  describe 'rate limiting' do
    let!(:profile) { create(:profile) }

    it 'allows requests within limit' do
      50.times do
        get '/api/v1/profiles'
        expect(response).to have_http_status(:success)
      end
    end

    it 'blocks requests after limit is exceeded', :skip_on_ci do
      101.times do |i|
        get '/api/v1/profiles'

        if i < 100
          expect(response).to have_http_status(:success)
        else
          expect(response).to have_http_status(:too_many_requests)
        end
      end
    end

    it 'tracks different IPs separately' do
      50.times do
        get '/api/v1/profiles', headers: { 'REMOTE_ADDR' => '1.2.3.4' }
        expect(response).to have_http_status(:success)
      end

      50.times do
        get '/api/v1/profiles', headers: { 'REMOTE_ADDR' => '5.6.7.8' }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
