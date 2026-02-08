# frozen_string_literal: true

module Profiles
  module Github
    class HtmlParser
      def initialize(html, update_name: false)
        @doc = Nokogiri::HTML(html)
        @update_name = update_name
      end

      def parse
        data = {
          github_username: extract_username,
          followers: extract_followers,
          following: extract_following,
          stars: extract_stars,
          contributions_last_year: extract_contributions,
          avatar_url: extract_avatar,
          location: extract_location,
          organizations: extract_organizations
        }

        data[:name] = extract_name if @update_name
        data
      end

      private

      attr_reader :doc

      def extract_counter_stat(link_selector, counter_selector: Selectors::BOLD_TEXT)
        link = doc.at_css(link_selector)
        return 0 unless link

        number_text = link.at_css(counter_selector)&.text&.strip
        number_text ||= link.at_css(Selectors::COUNTER_COMPONENT)&.text&.strip
        number_text ||= link.text.scan(/\d+/).first

        parse_number(number_text)
      end

      def extract_name
        name = doc.at_css(Selectors::NAME_SELECTORS[0])&.text&.strip
        name || doc.at_css(Selectors::NAME_SELECTORS[1])&.text&.strip
      end

      def extract_username
        username = doc.at_css(Selectors::USERNAME_SELECTORS[0])&.text&.strip
        username || doc.at_css(Selectors::USERNAME_SELECTORS[1])&.text&.strip
      end

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

      def extract_avatar
        avatar = doc.at_css(Selectors::AVATAR_SELECTORS[0])&.[]("src")
        avatar ||= doc.at_css(Selectors::AVATAR_SELECTORS[1])&.[]("content")

        avatar = normalize_url(avatar)
        avatar&.gsub(/s=64&/, "")
      end

      def extract_location
        location_item = doc.at_css(Selectors::LOCATION_CONTAINER)
        return nil unless location_item
        location_item.at_css(Selectors::LOCATION_LABEL)&.text&.strip
      end

      def extract_organizations
        orgs = []

        doc.css(Selectors::ORGANIZATIONS_LINKS).each do |org_link|
          org_name = org_link["aria-label"]
          org_name ||= org_link.at_css("img")&.[]("alt")&.sub("@", "")

          orgs << org_name if org_name.present?
        end

        orgs.uniq
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

      def normalize_url(url)
        return nil if url.blank?
        return url if url.start_with?("http")
        return "https:#{url}" if url.start_with?("//")

        "https://github.com#{url}"
      end
    end
  end
end
