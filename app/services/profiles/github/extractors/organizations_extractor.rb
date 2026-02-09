# frozen_string_literal: true

module Profiles
  module Github
    module Extractors
      # Extracts organizations from a GitHub profile page.
      class OrganizationsExtractor < ApplicationService
        def initialize(doc)
          @doc = doc
        end

        def call
          Success(organizations: extract_organizations)
        end

        private

        attr_reader :doc

        def extract_organizations
          orgs = []

          doc.css(Selectors::ORGANIZATIONS_LINKS).each do |org_link|
            org_name = org_link["aria-label"]
            org_name ||= org_link.at_css("img")&.[]("alt")&.sub("@", "")

            orgs << org_name if org_name.present?
          end

          orgs.uniq
        end
      end
    end
  end
end
