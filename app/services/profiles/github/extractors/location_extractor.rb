# frozen_string_literal: true

module Profiles
  module Github
    module Extractors
      class LocationExtractor < ApplicationService
        def initialize(doc)
          @doc = doc
        end

        def call
          Success(location: extract_location)
        end

        private

        attr_reader :doc

        def extract_location
          location_item = doc.at_css(Selectors::LOCATION_CONTAINER)
          return nil unless location_item
          location_item.at_css(Selectors::LOCATION_LABEL)&.text&.strip
        end
      end
    end
  end
end
