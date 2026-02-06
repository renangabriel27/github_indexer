require 'rails_helper'

RSpec.describe 'GET /api/v1/profiles/:id', type: :request do
  include_context 'Profile GitHub API stubs'
  describe 'successful response' do
    let(:profile) do
      create(:profile,
             name: 'Test User',
             github_username: 'testuser',
             followers: 100,
             following: 50,
             stars: 200,
             contributions_last_year: 150,
             location: 'San Francisco',
             organizations: ['Org1', 'Org2'])
    end

    subject { get "/api/v1/profiles/#{profile.id}" }

    it 'returns profile with 200 status' do
      subject

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end

    it 'returns correct profile data' do
      subject

      json = JSON.parse(response.body)

      expect(json).to have_key('data')
      expect(json['data']['id']).to eq(profile.id)
      expect(json['data']['name']).to eq('Test User')
      expect(json['data']['github_username']).to eq('testuser')
    end

    it 'includes all profile fields' do
      subject

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

    it 'returns correct field values' do
      subject

      json = JSON.parse(response.body)
      profile_data = json['data']

      expect(profile_data['followers']).to eq(100)
      expect(profile_data['following']).to eq(50)
      expect(profile_data['stars']).to eq(200)
      expect(profile_data['contributions_last_year']).to eq(150)
      expect(profile_data['location']).to eq('San Francisco')
      expect(profile_data['organizations']).to eq(['Org1', 'Org2'])
    end

    it 'returns empty organizations array when nil' do
      profile.update(organizations: nil)

      subject

      json = JSON.parse(response.body)
      expect(json['data']['organizations']).to eq([])
    end

    context 'with nullable fields' do
      let(:profile) do
        create(:profile,
               short_github_url: nil,
               followers: nil,
               following: nil,
               stars: nil,
               contributions_last_year: nil,
               avatar_url: nil,
               location: nil)
      end

      it 'handles nil values correctly' do
        subject

        json = JSON.parse(response.body)
        profile_data = json['data']

        expect(profile_data['short_github_url']).to be_nil
        expect(profile_data['followers']).to be_nil
        expect(profile_data['following']).to be_nil
        expect(profile_data['stars']).to be_nil
        expect(profile_data['contributions_last_year']).to be_nil
        expect(profile_data['avatar_url']).to be_nil
        expect(profile_data['location']).to be_nil
      end
    end
  end

  describe 'error handling' do
    it 'returns 404 for non-existent profile' do
      get '/api/v1/profiles/99999'

      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to include('application/json')
    end

    it 'returns error message for non-existent profile' do
      get '/api/v1/profiles/99999'

      json = JSON.parse(response.body)

      expect(json).to have_key('error')
      expect(json['error']).to eq('Not found')
    end

    it 'returns 404 for invalid ID format' do
      get '/api/v1/profiles/invalid'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'response format' do
    let(:profile) { create(:profile) }

    it 'returns valid JSON' do
      get "/api/v1/profiles/#{profile.id}"

      expect { JSON.parse(response.body) }.not_to raise_error
    end

    it 'returns data as object, not array' do
      get "/api/v1/profiles/#{profile.id}"

      json = JSON.parse(response.body)

      expect(json['data']).to be_a(Hash)
      expect(json['data']).not_to be_an(Array)
    end
  end
end

