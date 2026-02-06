# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles Edit', type: :feature do
  include_context 'Profile GitHub API stubs'
  let(:profile) do
    create(:profile,
           name: 'Original Name',
           github_username: 'originaluser',
           avatar_url: 'https://example.com/avatar.jpg',
           last_scanned_at: 1.hour.ago)
  end

  describe 'page display' do
    it 'displays the edit form with current values' do
      visit edit_profile_path(profile)

      expect(page).to have_content('Editar Perfil')
      expect(page).to have_content('@originaluser')
      expect(page).to have_field('profile[name]', with: 'Original Name')
      expect(page).to have_field('profile[github_username]', with: 'originaluser')
    end
  end

  describe 'form submission' do
    it 'updates profile with valid data' do
      visit edit_profile_path(profile)

      fill_in 'profile[name]', with: 'Updated Name'
      fill_in 'profile[github_username]', with: 'updateduser'

      click_button('Atualizar Perfil')

      expect(page).to have_current_path(profile_path(profile))
      expect(page).to have_content('Atualizado!')
      expect(page).to have_content('Updated Name')
    end

    it 'displays validation errors for empty fields' do
      visit edit_profile_path(profile)

      fill_in 'profile[name]', with: ''
      fill_in 'profile[github_username]', with: ''
      click_button('Atualizar Perfil')

      expect(page).to have_content('Editar Perfil')
      expect(page).to have_content('erro')
    end

    it 'displays validation errors for duplicate github_username' do
      other_profile = create(:profile, github_username: 'existinguser')
      visit edit_profile_path(profile)

      fill_in 'profile[github_username]', with: 'existinguser'
      click_button('Atualizar Perfil')

      expect(page).to have_content(/já está em uso|has already been taken|já foi utilizado/i)
    end
  end

  describe 'navigation' do
    it 'navigates to profile show page when clicking cancel' do
      visit edit_profile_path(profile)

      click_link('Cancelar')

      expect(page).to have_current_path(profile_path(profile))
    end

    it 'navigates to profile show page when clicking back link' do
      visit edit_profile_path(profile)

      click_link('Voltar para o perfil')

      expect(page).to have_current_path(profile_path(profile))
    end
  end

  describe 'danger zone' do
    it 'opens delete confirmation modal when clicking delete button', :js do
      visit edit_profile_path(profile)

      find('button', text: 'Remover Perfil').click

      expect(page).to have_content('Confirmar Exclusão')
      expect(page).to have_content('@originaluser')
    end
  end
end
