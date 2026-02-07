# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles Delete', type: :feature do
  include_context 'Profile GitHub API stubs'
  let(:profile) do
    create(:profile,
           name: 'Test User',
           github_username: 'testuser')
  end

  describe 'delete modal' do
    it 'opens delete confirmation modal when clicking "Remover" button', :js do
      visit profile_path(profile)

      # Click the trigger button
      find('button', text: 'Remover', match: :first).click

      # Wait for modal to appear
      within('[role="dialog"]', visible: true) do
        expect(page).to have_content('Confirmar Exclusão')
        expect(page).to have_content('@testuser')
        expect(page).to have_button('Cancelar')
        expect(page).to have_button('Remover')
      end
    end

    it 'closes modal when clicking cancel', :js do
      visit profile_path(profile)

      # Open modal
      find('button', text: 'Remover', match: :first).click
      expect(page).to have_selector('[role="dialog"]', visible: true)

      # Click cancel button
      within('[role="dialog"]') do
        click_button('Cancelar')
      end

      # Modal should disappear
      expect(page).not_to have_selector('[role="dialog"]', visible: true)
      expect(Profile.find_by(id: profile.id)).to be_present
    end

    it 'opens delete confirmation modal from edit page', :js do
      visit edit_profile_path(profile)

      # Click the trigger button (different text on edit page)
      find('button', text: 'Remover Perfil').click

      # Modal should appear
      within('[role="dialog"]', visible: true) do
        expect(page).to have_content('Confirmar Exclusão')
        expect(page).to have_content('@testuser')
      end
    end
  end

  describe 'profile deletion' do
    it 'deletes profile when confirming deletion', :js do
      visit profile_path(profile)

      # Open modal
      find('button', text: 'Remover', match: :first).click
      expect(page).to have_selector('[role="dialog"]', visible: true)

      # Confirm deletion
      within('[role="dialog"]') do
        click_button('Remover')
      end

      # Should redirect to profiles index
      expect(page).to have_current_path(profiles_path)
      expect(Profile.find_by(id: profile.id)).to be_nil
    end

    it 'deletes profile from edit page', :js do
      visit edit_profile_path(profile)

      # Open modal
      find('button', text: 'Remover Perfil').click
      expect(page).to have_selector('[role="dialog"]', visible: true)

      # Confirm deletion
      within('[role="dialog"]') do
        click_button('Remover')
      end

      # Should redirect to profiles index
      expect(page).to have_current_path(profiles_path)
      expect(Profile.find_by(id: profile.id)).to be_nil
    end

    it 'removes only the selected profile', :js do
      profile1 = create(:profile, name: 'User One', github_username: 'userone')
      profile2 = create(:profile, name: 'User Two', github_username: 'usertwo')

      visit profile_path(profile1)

      # Open modal and confirm deletion
      find('button', text: 'Remover', match: :first).click
      within('[role="dialog"]') do
        click_button('Remover')
      end

      # Verify only profile1 was deleted
      expect(page).to have_current_path(profiles_path)
      expect(Profile.find_by(id: profile1.id)).to be_nil
      expect(Profile.find_by(id: profile2.id)).to be_present
    end
  end
end
