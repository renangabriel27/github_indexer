# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  include_context 'Profile GitHub API stubs'

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:github_username) }

    describe 'github_username' do
      it 'validates uniqueness case insensitively' do
        create(:profile, github_username: 'testuser')
        duplicate = build(:profile, github_username: 'TestUser')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:github_username]).to be_present
      end

      it 'accepts valid usernames' do
        %w[user123 user-name User123 a a-b-c].each do |username|
          stub_github_api(username.downcase)
          expect(build(:profile, github_username: username)).to be_valid
        end
      end

      it 'rejects invalid format' do
        %w[user_name user.name user@name].each do |username|
          profile = build(:profile, github_username: username)
          expect(profile).not_to be_valid
          expect(profile.errors[:github_username]).to include('inválido. Use apenas letras, números e hífens')
        end
      end

      it 'rejects usernames longer than 39 characters' do
        profile = build(:profile, github_username: 'a' * 40)
        expect(profile).not_to be_valid
        expect(profile.errors[:github_username]).to include('deve ter no máximo 39 caracteres')
      end

      it 'rejects usernames starting or ending with hyphen' do
        %w[-username username-].each do |username|
          stub_github_api(username)
          profile = build(:profile, github_username: username)
          expect(profile).not_to be_valid
          expect(profile.errors[:github_username]).to include('não pode começar ou terminar com hífen')
        end
      end

      it 'rejects usernames with consecutive hyphens' do
        stub_github_api('user--name')
        profile = build(:profile, github_username: 'user--name')
        expect(profile).not_to be_valid
        expect(profile.errors[:github_username]).to include('não pode conter hífens consecutivos')
      end
    end
  end

  describe 'callbacks' do
    it 'normalizes github_username before validation' do
      stub_github_api('username')
      profile = build(:profile, github_username: '  UserName  ')
      profile.valid?
      expect(profile.github_username).to eq('username')
    end
  end
end
