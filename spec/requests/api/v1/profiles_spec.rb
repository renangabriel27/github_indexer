require 'rails_helper'

RSpec.describe 'API::Profiles' do
  describe 'GET /api/v1/profiles' do
    let!(:profiles) { create_list(:profile, 15) }

    it 'returns paginated profiles' do
      get '/api/v1/profiles', params: { page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data'].size).to eq(10)
      expect(json['meta']['current_page']).to eq(1)
      expect(json['meta']['total_count']).to eq(15)
    end

    it 'searches profiles' do
      create(:profile, name: 'Unique Name')

      get '/api/v1/profiles', params: { q: 'Unique' }

      json = JSON.parse(response.body)
      expect(json['data'].size).to eq(1)
    end
  end

  describe 'GET /api/profiles/:id' do
    let(:profile) { create(:profile) }

    it 'returns profile' do
      get "/api/v1/profiles/#{profile.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(profile.id)
    end

    it 'returns 404 for missing profile' do
      get '/api/v1/profiles/99999'

      expect(response).to have_http_status(:not_found)
    end
  end
end
