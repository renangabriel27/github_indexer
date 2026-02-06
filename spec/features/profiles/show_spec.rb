# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles Show', type: :feature do
  include_context 'Profile GitHub API stubs'
  let(:profile) do
    create(:profile,
           name: 'Test User',
           github_username: 'testuser',
           followers: 100,
           following: 50,
           stars: 200,
           contributions_last_year: 150,
           location: 'San Francisco',
           organizations: ['Org1', 'Org2'],
           avatar_url: 'https://example.com/avatar.jpg',
           scraping_status: 'completed',
           last_scanned_at: 1.hour.ago)
  end

  describe 'page display' do
    it 'displays profile information' do
      visit profile_path(profile)

      expect(page).to have_content('Test User')
      expect(page).to have_content('testuser')
      expect(page).to have_content('100')
      expect(page).to have_content('Followers')
      expect(page).to have_content('200')
      expect(page).to have_content('Stars')
    end

    it 'displays location and organizations when present' do
      visit profile_path(profile)

      expect(page).to have_content('San Francisco')
      expect(page).to have_content('Organizações')
      expect(page).to have_content('Org1')
    end
  end

  describe 'action buttons' do
    it 'displays action buttons' do
      visit profile_path(profile)

      expect(page).to have_button('Re-escanear')
      expect(page).to have_link('Editar', href: edit_profile_path(profile))
      expect(page).to have_button('Remover')
    end

    it 'navigates to edit page when clicking "Editar"' do
      visit profile_path(profile)

      click_link('Editar')

      expect(page).to have_current_path(edit_profile_path(profile))
      expect(page).to have_content('Editar Perfil')
    end

    it 'opens delete confirmation modal when clicking "Remover"', :js do
      visit profile_path(profile)

      find('button', text: 'Remover', match: :first).click

      expect(page).to have_content('Confirmar Exclusão')
      expect(page).to have_content('@testuser')
    end
  end

  describe 'rescan functionality' do
    it 'shows success notice after rescan is initiated' do
      allow(RescanProfileJob).to receive(:perform_later)
      visit profile_path(profile)

      click_button('Re-escanear')

      expect(page).to have_content('Re-escaneamento iniciado!')
    end
  end

  describe 'navigation' do
    it 'navigates to profiles index when clicking back link' do
      visit profile_path(profile)

      click_link('Voltar para perfis')

      expect(page).to have_current_path(profiles_path)
    end
  end
end
