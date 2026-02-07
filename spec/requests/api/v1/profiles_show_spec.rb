require 'rails_helper'

RSpec.describe 'GET /api/v1/profiles/:id', type: :request do
  include_context 'Profile GitHub API stubs'

  describe 'successful response' do
    let(:profile) do
      create(:profile,
             name: 'Test User',
             github_username: 'testuser',
             followers: 100,
             location: 'San Francisco',
             organizations: [ 'Org1', 'Org2' ])
    end

    it 'returns profile with correct data and structure' do
      get "/api/v1/profiles/#{profile.id}"

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')

      json = JSON.parse(response.body)

      expect(json).to have_key('data')
      expect(json['data']).to be_a(Hash)
      expect(json['data']['id']).to eq(profile.id)
      expect(json['data']['name']).to eq('Test User')
      expect(json['data']['github_username']).to eq('testuser')
    end

    it 'includes all profile fields' do
      get "/api/v1/profiles/#{profile.id}"

      json = JSON.parse(response.body)
      profile_data = json['data']

      expect(profile_data).to include(
        'id',
        'name',
        'github_username',
        'short_github_url',
        'followers',
        'following',
        'stars',
        'contributions_last_year',
        'avatar_url',
        'location',
        'organizations'
      )
    end
  end

  describe 'error handling' do
    it 'returns 404 with error message for non-existent profile' do
      get '/api/v1/profiles/99999'

      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to include('application/json')

      json = JSON.parse(response.body)
      expect(json['error']).to be_a(Hash)
      expect(json['error']['code']).to eq('not_found')
      expect(json['error']['message']).to include('Couldn\'t find Profile')
    end
  end
end
