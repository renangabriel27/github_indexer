# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::GithubSelectors do
  describe 'selector constants' do
    it 'defines NAME_SELECTORS' do
      expect(described_class::NAME_SELECTORS).to eq(['[itemprop="name"]', '.p-name'])
    end

    it 'defines USERNAME_SELECTORS' do
      expect(described_class::USERNAME_SELECTORS).to eq(['[itemprop="additionalName"]', '.vcard-username'])
    end

    it 'defines statistics selectors' do
      expect(described_class::FOLLOWERS_LINK).to eq('a[href*="tab=followers"]')
      expect(described_class::FOLLOWING_LINK).to eq('a[href*="tab=following"]')
      expect(described_class::STARS_LINK).to eq('a[href*="tab=stars"]')
      expect(described_class::CONTRIBUTIONS_HEADING).to eq('h2#js-contribution-activity-description, h2[id*="contribution"]')
    end

    it 'defines counter element selectors' do
      expect(described_class::BOLD_TEXT).to eq('.text-bold')
      expect(described_class::COUNTER_COMPONENT).to eq('[data-view-component="true"][class*="Counter"]')
    end

    it 'defines profile detail selectors' do
      expect(described_class::AVATAR_SELECTORS).to eq(['.avatar-user', 'meta[property="og:image"]'])
      expect(described_class::LOCATION_CONTAINER).to eq('[itemprop="homeLocation"]')
      expect(described_class::LOCATION_LABEL).to eq('.p-label')
      expect(described_class::ORGANIZATIONS_LINKS).to eq('a[itemprop="follows"]')
    end

    it 'defines page validation selectors' do
      expect(described_class::TITLE_TAG).to eq('title')
      expect(described_class::PROFILE_ELEMENT_MARKERS).to include('vcard-username', 'avatar-user', 'p-name', 'itemprop="name"')
    end

    it 'defines error patterns' do
      expect(described_class::ERROR_PATTERNS).to be_an(Array)
      expect(described_class::ERROR_PATTERNS.size).to eq(4)
      expect(described_class::ERROR_PATTERNS.all? { |p| p.is_a?(Regexp) }).to be true
    end

    it 'defines wait selector' do
      expect(described_class::CONTRIBUTION_WAIT_SELECTOR).to eq('h2[id*="contribution"]')
    end
  end

  describe 'selector freezing' do
    it 'freezes all array constants' do
      expect(described_class::NAME_SELECTORS).to be_frozen
      expect(described_class::USERNAME_SELECTORS).to be_frozen
      expect(described_class::AVATAR_SELECTORS).to be_frozen
      expect(described_class::PROFILE_ELEMENT_MARKERS).to be_frozen
      expect(described_class::ERROR_PATTERNS).to be_frozen
    end

    it 'freezes all string constants' do
      expect(described_class::FOLLOWERS_LINK).to be_frozen
      expect(described_class::BOLD_TEXT).to be_frozen
      expect(described_class::TITLE_TAG).to be_frozen
    end
  end
end
