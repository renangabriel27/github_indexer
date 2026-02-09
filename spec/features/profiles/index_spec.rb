# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles Index', type: :feature do
  include_context 'Profile GitHub API stubs'

  describe 'page display' do
    it 'displays the hero section with search functionality' do
      visit profiles_path

      expect(page).to have_content('Descubra perfis incríveis')
      expect(page).to have_content('do GitHub')
      expect(page).to have_field('q', placeholder: 'Buscar perfil...')
      expect(page).to have_link('Adicionar Perfil', href: new_profile_path)
    end
  end

  describe 'search functionality' do
    let!(:profile1) { create(:profile, name: 'John Doe', github_username: 'johndoe') }
    let!(:profile2) { create(:profile, name: 'Jane Smith', github_username: 'janesmith') }

    it 'searches profiles by name' do
      visit profiles_path

      fill_in 'q', with: 'John'
      click_button(type: 'submit')

      expect(page).to have_content('John Doe')
      expect(page).not_to have_content('Jane Smith')
    end

    it 'returns empty results when no match' do
      visit profiles_path

      fill_in 'q', with: 'NonExistent'
      click_button(type: 'submit')

      expect(page).to have_content('Nenhum perfil encontrado')
    end
  end

  describe 'profile cards display' do
    let!(:profile) do
      create(:profile,
             name: 'Test User',
             github_username: 'testuser',
             followers: 100,
             stars: 50)
    end

    it 'displays profile cards with correct information' do
      visit profiles_path

      expect(page).to have_content('Test User')
      expect(page).to have_content('testuser')
      expect(page).to have_link(href: profile_path(profile))
    end
  end

  describe 'empty state' do
    it 'displays empty state when no profiles exist' do
      visit profiles_path

      expect(page).to have_content('Nenhum perfil encontrado')
      expect(page).to have_link('Adicionar Primeiro Perfil', href: new_profile_path)
    end
  end

  describe 'navigation' do
    it 'navigates to new profile page when clicking "Adicionar Perfil"' do
      visit profiles_path

      click_link('Adicionar Perfil')

      expect(page).to have_current_path(new_profile_path)
    end

    it 'navigates to profile show page when clicking on a profile card' do
      profile = create(:profile, name: 'Test User', github_username: 'testuser')
      visit profiles_path

      # Click on the first profile name link in the card
      first(:link, 'Test User').click

      expect(page).to have_current_path(profile_path(profile))
      expect(page).to have_content('Test User')
    end
  end
end
