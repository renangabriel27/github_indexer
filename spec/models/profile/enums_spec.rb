# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  include_context 'Profile GitHub API stubs'

  describe 'enums' do
    describe 'scraping_status' do
      it 'defines correct enum values' do
        expect(Profile.scraping_statuses.keys).to match_array(%w[pending processing completed failed])
      end
    end
  end
end

