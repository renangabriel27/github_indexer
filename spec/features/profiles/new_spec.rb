# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles New', type: :feature do
  include_context 'Profile GitHub API stubs'

  describe 'page display' do
    it 'displays the new profile form' do
      visit new_profile_path

      expect(page).to have_content('Adicionar Novo Perfil')
      expect(page).to have_field('profile[name]')
      expect(page).to have_field('profile[github_username]')
      expect(page).to have_button('Salvar Perfil')
      expect(page).to have_link('Cancelar')
      expect(page).to have_link('Voltar para perfis')
    end
  end

  describe 'form submission' do
    it 'creates profile with valid data' do
      visit new_profile_path

      fill_in 'profile[name]', with: 'New User'
      fill_in 'profile[github_username]', with: 'newuser'

      click_button('Salvar Perfil')

      expect(page).to have_content('Perfil criado!')
      expect(page).to have_content('New User')

      created_profile = Profile.find_by(github_username: 'newuser')
      expect(created_profile).to be_present
      expect(page).to have_current_path(profile_path(created_profile))
    end

    it 'displays validation errors for empty fields' do
      visit new_profile_path

      fill_in 'profile[name]', with: ''
      fill_in 'profile[github_username]', with: ''
      click_button('Salvar Perfil')

      # Should stay on the new page
      expect(page).to have_content('Adicionar Novo Perfil')
      # Should show error messages
      expect(page).to have_content(/erro/i)
    end

    it 'displays validation errors for duplicate github_username' do
      create(:profile, github_username: 'existinguser')
      visit new_profile_path

      fill_in 'profile[name]', with: 'Test User'
      fill_in 'profile[github_username]', with: 'existinguser'
      click_button('Salvar Perfil')

      # Should stay on the new page with validation errors
      expect(page).to have_content('Adicionar Novo Perfil')
      expect(page).to have_content(/já está em uso|has already been taken|já foi utilizado|erro/i)
    end
  end

  describe 'navigation' do
    it 'navigates to profiles index when clicking cancel button' do
      visit new_profile_path

      click_link('Cancelar')

      expect(page).to have_current_path(profiles_path)
    end

    it 'navigates to profiles index when clicking back link' do
      visit new_profile_path

      click_link('Voltar para perfis')

      expect(page).to have_current_path(profiles_path)
    end
  end
end
