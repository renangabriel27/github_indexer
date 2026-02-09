# frozen_string_literal: true

module Profiles
  module Github
    module Extractors
      class AvatarExtractor < ApplicationService
        def initialize(doc)
          @doc = doc
        end

        def call
          Success(avatar_url: extract_avatar)
        end

        private

        attr_reader :doc

        def extract_avatar
          avatar = doc.at_css(Selectors::AVATAR_SELECTORS[0])&.[]("src")
          avatar ||= doc.at_css(Selectors::AVATAR_SELECTORS[1])&.[]("content")

          avatar = normalize_url(avatar)
          avatar&.gsub(/s=64&/, "")
        end

        def normalize_url(url)
          return nil if url.blank?
          return url if url.start_with?("http")
          return "https:#{url}" if url.start_with?("//")

          "https://github.com#{url}"
        end
      end
    end
  end
end
