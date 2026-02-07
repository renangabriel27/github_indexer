# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  include_context 'Profile GitHub API stubs'

  describe 'callbacks' do
    describe 'before_validation :normalize_github_username' do
      it 'strips whitespace and converts to lowercase' do
        stub_github_api('username')
        profile = build(:profile, github_username: '  UserName  ')
        profile.valid?
        expect(profile.github_username).to eq('username')
      end
    end
  end
end
