# frozen_string_literal: true

module Profiles
  class GithubSelectors
    # Profile identification
    NAME_SELECTORS = ['[itemprop="name"]', '.p-name'].freeze
    USERNAME_SELECTORS = ['[itemprop="additionalName"]', '.vcard-username'].freeze

    # Statistics
    FOLLOWERS_LINK = 'a[href*="tab=followers"]'.freeze
    FOLLOWING_LINK = 'a[href*="tab=following"]'.freeze
    STARS_LINK = 'a[href*="tab=stars"]'.freeze
    CONTRIBUTIONS_HEADING = 'h2#js-contribution-activity-description, h2[id*="contribution"]'.freeze

    # Counter elements
    BOLD_TEXT = '.text-bold'.freeze
    COUNTER_COMPONENT = '[data-view-component="true"][class*="Counter"]'.freeze

    # Profile details
    AVATAR_SELECTORS = ['.avatar-user', 'meta[property="og:image"]'].freeze
    LOCATION_CONTAINER = '[itemprop="homeLocation"]'.freeze
    LOCATION_LABEL = '.p-label'.freeze
    ORGANIZATIONS_LINKS = 'a[itemprop="follows"]'.freeze

    # Page validation
    TITLE_TAG = 'title'.freeze
    PROFILE_ELEMENT_MARKERS = ['vcard-username', 'avatar-user', 'p-name', 'itemprop="name"'].freeze

    # Error patterns
    ERROR_PATTERNS = [
      /this is not the web page you are looking for/i,
      /there isn't a github pages site here/i,
      /page not found/i,
      /404.*not found/i
    ].freeze

    # Wait for dynamic content
    CONTRIBUTION_WAIT_SELECTOR = 'h2[id*="contribution"]'.freeze
  end
end
