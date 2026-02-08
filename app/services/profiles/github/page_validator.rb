# frozen_string_literal: true

module Profiles
  class ProfileNotFoundError < StandardError; end

  module Github
    class PageValidator
      def initialize(browser)
        @browser = browser
      end

      def validate!
        check_http_status_code
        check_page_title
        check_profile_elements
      end

      private

      attr_reader :browser

      def check_http_status_code
        return unless browser.respond_to?(:status)
        status = browser.status

        if status == 404
          raise ProfileNotFoundError, "Perfil não encontrado (404)"
        elsif status >= 400
          raise StandardError, "Erro HTTP #{status} ao acessar perfil"
        end
      rescue NoMethodError
        nil
      end

      def check_page_title
        title = browser.at_css(Selectors::TITLE_TAG)&.text&.downcase || ""

        if title.include?("404") || title.include?("not found")
          raise ProfileNotFoundError, "Perfil não encontrado"
        end
      end

      def check_profile_elements
        html = browser.body
        has_profile = Selectors::PROFILE_ELEMENT_MARKERS.any? { |marker| html.include?(marker) }
        return if has_profile

        if Selectors::ERROR_PATTERNS.any? { |pattern| html.match?(pattern) }
          raise ProfileNotFoundError, "Perfil não encontrado"
        end
      end
    end
  end
end
