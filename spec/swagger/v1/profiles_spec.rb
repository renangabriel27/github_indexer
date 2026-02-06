# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Profiles API', type: :request do
  before do
    # Mock GitHub API calls to avoid validation errors
    stub_request(:get, /api\.github\.com\/users\/\w+/)
      .to_return(
        status: 200,
        body: { type: 'User' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
  path '/api/v1/profiles' do
    get 'Lista perfis' do
      tags 'Profiles'
      description 'Retorna uma lista paginada de perfis do GitHub'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false,
                description: 'Número da página (padrão: 1)'
      parameter name: :per_page, in: :query, type: :integer, required: false,
                description: 'Itens por página (padrão: 10, máximo: 100)'
      parameter name: :offset, in: :query, type: :integer, required: false,
                description: 'Offset para paginação baseada em offset'
      parameter name: :search, in: :query, type: :string, required: false,
                description: 'Buscar perfis por nome ou username'
      parameter name: :q, in: :query, type: :string, required: false,
                description: 'Alias para o parâmetro search'

      response '200', 'Lista de perfis retornada com sucesso' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       github_username: { type: :string },
                       short_github_url: { type: :string, nullable: true },
                       followers: { type: :integer, nullable: true },
                       following: { type: :integer, nullable: true },
                       stars: { type: :integer, nullable: true },
                       contributions_last_year: { type: :integer, nullable: true },
                       avatar_url: { type: :string, nullable: true },
                       location: { type: :string, nullable: true },
                       organizations: {
                         type: :array,
                         items: { type: :string },
                         nullable: true
                       }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     per_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               }

        let(:page) { 1 }
        let(:per_page) { 10 }
        let!(:profiles) { create_list(:profile, 15) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['meta']).to be_present
          expect(data['meta']['current_page']).to eq(1)
        end
      end

      response '200', 'Busca de perfis' do
        schema '$ref' => '#/components/schemas/ProfilesResponse'

        before { Profile.destroy_all }

        let(:search) { 'Test' }
        let!(:profile1) { create(:profile, name: 'Test User') }
        let!(:profile2) { create(:profile, name: 'Another User', github_username: 'anotheruser') }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data'].length).to eq(1)
          expect(data['data'].first['name']).to eq('Test User')
        end
      end
    end
  end

  path '/api/v1/profiles/{id}' do
    get 'Mostra um perfil' do
      tags 'Profiles'
      description 'Retorna os detalhes de um perfil específico'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'ID do perfil'

      response '200', 'Perfil retornado com sucesso' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     github_username: { type: :string },
                     short_github_url: { type: :string, nullable: true },
                     followers: { type: :integer, nullable: true },
                     following: { type: :integer, nullable: true },
                     stars: { type: :integer, nullable: true },
                     contributions_last_year: { type: :integer, nullable: true },
                     avatar_url: { type: :string, nullable: true },
                     location: { type: :string, nullable: true },
                     organizations: {
                       anyOf: [
                         { type: :array, items: { type: :string } },
                         { type: :string }
                       ]
                     }
                   }
                 }
               }

        let(:id) { create(:profile).id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_present
          expect(data['data']['id']).to eq(id)
        end
      end

      response '404', 'Perfil não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let(:id) { 99999 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Not found')
        end
      end
    end
  end
end

