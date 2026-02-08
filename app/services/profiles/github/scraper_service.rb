# frozen_string_literal: true

module Profiles
  module Github
    class ScraperService < ApplicationService
      def initialize(profile, update_name: false)
        @profile = profile
        @github_url = "https://www.github.com/#{profile.github_username}"
        @update_name = update_name
        @error_handler = ErrorHandler.new(profile)
      end

      def call
        @profile.update(scraping_status: :processing)
        Success(perform_scraping)
      rescue ProfileNotFoundError => e
        @error_handler.handle_not_found_error(e)
      rescue StandardError => e
        @error_handler.handle_standard_error(e)
      end

      private

      def perform_scraping
        browser_manager = BrowserManager.new

        begin
          browser_manager.navigate_to(@github_url)
          PageValidator.new(browser_manager.browser).validate!
          browser_manager.wait_for_contributions(username: @profile.github_username)

          parsed_data = HtmlParser.new(browser_manager.html, update_name: @update_name).parse

          @profile.update!(
            **parsed_data,
            scraping_status: :completed,
            last_scanned_at: Time.current,
            last_error: nil
          )

          @profile
        ensure
          browser_manager.quit
        end
      end
    end
  end
end
