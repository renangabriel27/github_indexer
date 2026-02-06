# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  include_context 'Profile GitHub API stubs'

  describe 'validations' do
    describe 'name' do
      it { should validate_presence_of(:name) }
    end

    describe 'github_username' do
      it { should validate_presence_of(:github_username) }

      it 'validates uniqueness case insensitively' do
        create(:profile, github_username: 'testuser')
        duplicate = build(:profile, github_username: 'TestUser')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:github_username]).to be_present
      end

      context 'format validation' do
        it 'accepts valid usernames' do
          valid_usernames = ['user123', 'user-name', 'User123', 'a', 'a-b-c']
          valid_usernames.each do |username|
            stub_github_api(username.downcase)
            profile = build(:profile, github_username: username)
            expect(profile).to be_valid
          end
        end

        it 'rejects invalid format' do
          invalid_usernames = ['user_name', 'user.name', 'user@name', 'user name']
          invalid_usernames.each do |username|
            profile = build(:profile, github_username: username)
            expect(profile).not_to be_valid
            expect(profile.errors[:github_username]).to include('inválido. Use apenas letras, números e hífens')
          end
        end
      end

      context 'length validation' do
        it 'accepts usernames up to 39 characters' do
          username = 'a' * 39
          stub_github_api(username)
          profile = build(:profile, github_username: username)
          expect(profile).to be_valid
        end

        it 'rejects usernames longer than 39 characters' do
          username = 'a' * 40

          profile = build(:profile, github_username: username)
          expect(profile).not_to be_valid
          expect(profile.errors[:github_username]).to include('deve ter no máximo 39 caracteres')
        end
      end

      context 'custom format validations' do
        it 'rejects usernames starting with hyphen' do

          stub_github_api('-username')
          profile = build(:profile, github_username: '-username')
          expect(profile).not_to be_valid
          expect(profile.errors[:github_username]).to include('não pode começar ou terminar com hífen')
        end

        it 'rejects usernames ending with hyphen' do
          stub_github_api('username-')
          profile = build(:profile, github_username: 'username-')
          expect(profile).not_to be_valid
          expect(profile.errors[:github_username]).to include('não pode começar ou terminar com hífen')
        end

        it 'rejects usernames with consecutive hyphens' do
          stub_github_api('user--name')
          profile = build(:profile, github_username: 'user--name')
          expect(profile).not_to be_valid
          expect(profile.errors[:github_username]).to include('não pode conter hífens consecutivos')
        end
      end

      context 'organization validation' do
        it 'rejects organization usernames' do
          stub_github_api('rails', type: 'Organization')

          profile = build(:profile, github_username: 'rails')
          expect(profile).not_to be_valid
          expect(profile.errors[:github_username]).to include('não pode ser uma organização')
        end

        it 'accepts user usernames' do
          stub_github_api('matz', type: 'User')

          profile = build(:profile, github_username: 'matz')
          expect(profile).to be_valid
        end

        it 'handles API errors gracefully' do
          stub_github_api('invalid', status: 404)

          profile = build(:profile, github_username: 'invalid')
          expect { profile.valid? }.not_to raise_error
        end
      end
    end
  end
end

