require 'rails_helper'

RSpec.describe 'GET /api/v1/profiles', type: :request do
  include_context 'Profile GitHub API stubs'

  describe 'pagination' do
    before do
      create_list(:profile, 25)
    end

    it 'returns paginated profiles with correct structure' do
      get '/api/v1/profiles', params: { page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data']).to be_an(Array)
      expect(json['data'].size).to eq(10)
      expect(json['meta']['current_page']).to eq(1)
      expect(json['meta']['per_page']).to eq(10)
      expect(json['meta']['total_count']).to eq(25)
      expect(json['meta']['total_pages']).to eq(3)
    end

    it 'caps per_page at maximum of 100' do
      get '/api/v1/profiles', params: { per_page: 150 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['meta']['per_page']).to eq(100)
    end

    it 'uses offset for pagination' do
      get '/api/v1/profiles', params: { offset: 10, per_page: 5 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data'].size).to eq(5)
    end

    it 'returns empty array when no profiles exist' do
      Profile.destroy_all
      get '/api/v1/profiles'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data']).to eq([])
      expect(json['meta']['total_count']).to eq(0)
    end
  end

  describe 'search' do
    let!(:profile1) { create(:profile, name: 'John Doe', github_username: 'johndoe') }
    let!(:profile2) { create(:profile, name: 'Jane Smith', github_username: 'janesmith') }

    it 'searches profiles by name' do
      get '/api/v1/profiles', params: { q: 'John' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data'].size).to eq(1)
      expect(json['data'].first['id']).to eq(profile1.id)
    end

    it 'searches profiles by github_username' do
      get '/api/v1/profiles', params: { q: 'jane' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data'].size).to eq(1)
      expect(json['data'].first['id']).to eq(profile2.id)
    end
  end

  describe 'ordering' do
    let!(:old_profile) { create(:profile, created_at: 2.days.ago) }
    let!(:new_profile) { create(:profile, created_at: Time.current) }

    it 'returns profiles ordered by created_at desc' do
      get '/api/v1/profiles'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      ids = json['data'].map { |p| p['id'] }
      expect(ids.first).to eq(new_profile.id)
      expect(ids.last).to eq(old_profile.id)
    end
  end

  describe 'response structure' do
    let!(:profile) { create(:profile) }

    it 'returns correct JSON structure with all fields' do
      get '/api/v1/profiles'

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')

      json = JSON.parse(response.body)

      expect(json).to have_key('data')
      expect(json).to have_key('meta')
      expect(json['data']).to be_an(Array)

      profile_data = json['data'].first
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
end

