# frozen_string_literal: true

module Profiles
  module Github
    module Extractors
      class StatisticsExtractor < ApplicationService
        def initialize(doc)
          @doc = doc
        end

        def call
          Success(
            followers: extract_followers,
            following: extract_following,
            stars: extract_stars,
            contributions_last_year: extract_contributions
          )
        end

        private

        attr_reader :doc

        def extract_followers
          extract_counter_stat(Selectors::FOLLOWERS_LINK)
        end

        def extract_following
          extract_counter_stat(Selectors::FOLLOWING_LINK)
        end

        def extract_stars
          extract_counter_stat(Selectors::STARS_LINK)
        end

        def extract_contributions
          node = doc.at_css(Selectors::CONTRIBUTIONS_HEADING)
          return 0 unless node

          text = node.text.gsub(/\s+/, " ").strip
          number = text[/[\d,.]+/]

          return 0 unless number
          number.delete(".,").to_i
        end

        def extract_counter_stat(link_selector, counter_selector: Selectors::BOLD_TEXT)
          link = doc.at_css(link_selector)
          return 0 unless link

          number_text = link.at_css(counter_selector)&.text&.strip
          number_text ||= link.at_css(Selectors::COUNTER_COMPONENT)&.text&.strip
          number_text ||= link.text.scan(/\d+/).first

          parse_number(number_text)
        end

        def parse_number(text)
          return 0 if text.blank?

          clean_text = text.gsub(/[,\s]/, "")

          multiplier = case clean_text.downcase
          when /k$/i then 1_000
          when /m$/i then 1_000_000
          else 1
          end

          number = clean_text.gsub(/[^\d.]/, "").to_f
          (number * multiplier).to_i
        end
      end
    end
  end
end
