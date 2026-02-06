require 'rails_helper'

RSpec.describe 'GET /api/v1/profiles', type: :request do
  include_context 'Profile GitHub API stubs'
  describe 'pagination' do
    before do
      create_list(:profile, 25)
    end

    context 'with page parameter' do
      it 'returns paginated profiles' do
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

      it 'returns second page' do
        get '/api/v1/profiles', params: { page: 2, per_page: 10 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].size).to eq(10)
        expect(json['meta']['current_page']).to eq(2)
      end

      it 'returns last page with remaining items' do
        get '/api/v1/profiles', params: { page: 3, per_page: 10 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].size).to eq(5)
        expect(json['meta']['current_page']).to eq(3)
      end

      it 'defaults to page 1 when page is 0 or negative' do
        get '/api/v1/profiles', params: { page: 0, per_page: 10 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['meta']['current_page']).to eq(1)
      end
    end

    context 'with per_page parameter' do
      it 'uses default per_page when not provided' do
        get '/api/v1/profiles'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['meta']['per_page']).to eq(10)
        expect(json['data'].size).to be <= 10
      end

      it 'respects per_page parameter' do
        get '/api/v1/profiles', params: { per_page: 5 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['meta']['per_page']).to eq(5)
        expect(json['data'].size).to eq(5)
      end

      it 'caps per_page at maximum of 100' do
        get '/api/v1/profiles', params: { per_page: 150 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['meta']['per_page']).to eq(100)
      end

      it 'uses default when per_page is 0 or negative' do
        get '/api/v1/profiles', params: { per_page: 0 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['meta']['per_page']).to eq(10)
      end
    end

    context 'with offset parameter' do
      it 'uses offset for pagination' do
        get '/api/v1/profiles', params: { offset: 10, per_page: 5 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].size).to eq(5)
      end

      it 'prioritizes offset over page when both are provided' do
        get '/api/v1/profiles', params: { page: 2, offset: 5, per_page: 10 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].size).to eq(10)
      end
    end

    context 'with empty results' do
      before { Profile.destroy_all }

      it 'returns empty array with correct meta' do
        get '/api/v1/profiles'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data']).to eq([])
        expect(json['meta']['total_count']).to eq(0)
        expect(json['meta']['total_pages']).to eq(1)
      end
    end
  end

  describe 'search' do
    let!(:profile1) { create(:profile, name: 'John Doe', github_username: 'johndoe') }
    let!(:profile2) { create(:profile, name: 'Jane Smith', github_username: 'janesmith') }
    let!(:profile3) { create(:profile, name: 'Bob Johnson', github_username: 'bobjohnson') }

    context 'with q parameter' do
      it 'searches profiles by name' do
        get '/api/v1/profiles', params: { q: 'John' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].size).to eq(2)
        expect(json['data'].map { |p| p['id'] }).to contain_exactly(profile1.id, profile3.id)
      end

      it 'searches profiles by github_username' do
        get '/api/v1/profiles', params: { q: 'jane' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].size).to eq(1)
        expect(json['data'].first['id']).to eq(profile2.id)
      end

      it 'returns empty results when no match' do
        get '/api/v1/profiles', params: { q: 'NonExistent' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data']).to eq([])
      end
    end

    context 'with search parameter' do
      it 'searches profiles by name' do
        get '/api/v1/profiles', params: { search: 'John' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].size).to eq(2)
      end

      it 'prioritizes search over q when both are provided' do
        get '/api/v1/profiles', params: { q: 'Jane', search: 'John' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].map { |p| p['id'] }).to contain_exactly(profile1.id, profile3.id)
      end
    end

    context 'with pagination and search' do
      before { create_list(:profile, 10, name: 'Test User') }

      it 'paginates search results' do
        get '/api/v1/profiles', params: { q: 'Test', page: 1, per_page: 5 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].size).to eq(5)
        expect(json['meta']['total_count']).to eq(10)
      end
    end
  end

  describe 'ordering' do
    let!(:old_profile) { create(:profile, created_at: 2.days.ago) }
    let!(:middle_profile) { create(:profile, created_at: 1.day.ago) }
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

    it 'returns correct JSON structure' do
      get '/api/v1/profiles'

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')

      json = JSON.parse(response.body)

      expect(json).to have_key('data')
      expect(json).to have_key('meta')
      expect(json['data']).to be_an(Array)
      expect(json['meta']).to be_a(Hash)
    end

    it 'includes all profile fields in response' do
      get '/api/v1/profiles'

      json = JSON.parse(response.body)
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

    it 'includes correct pagination meta structure' do
      get '/api/v1/profiles', params: { page: 1, per_page: 10 }

      json = JSON.parse(response.body)

      expect(json['meta']).to include(
        'current_page',
        'per_page',
        'total_pages',
        'total_count'
      )
      expect(json['meta']['current_page']).to be_a(Integer)
      expect(json['meta']['per_page']).to be_a(Integer)
      expect(json['meta']['total_pages']).to be_a(Integer)
      expect(json['meta']['total_count']).to be_a(Integer)
    end
  end
end

