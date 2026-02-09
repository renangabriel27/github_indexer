# frozen_string_literal: true

module Profiles
  module Github
    module Extractors
      class IdentityExtractor < ApplicationService
        def initialize(doc, update_name: false)
          @doc = doc
          @update_name = update_name
        end

        def call
          data = { github_username: extract_username }
          data[:name] = extract_name if @update_name
          Success(data)
        end

        private

        attr_reader :doc

        def extract_username
          username = doc.at_css(Selectors::USERNAME_SELECTORS[0])&.text&.strip
          username || doc.at_css(Selectors::USERNAME_SELECTORS[1])&.text&.strip
        end

        def extract_name
          name = doc.at_css(Selectors::NAME_SELECTORS[0])&.text&.strip
          name || doc.at_css(Selectors::NAME_SELECTORS[1])&.text&.strip
        end
      end
    end
  end
end
