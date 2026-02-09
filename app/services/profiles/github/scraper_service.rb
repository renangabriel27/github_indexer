# frozen_string_literal: true

module Profiles
  module Github
    class ScraperService < ApplicationService
      def initialize(profile, update_name: false)
        @profile = profile
        @github_url = "https://www.github.com/#{profile.github_username}"
        @update_name = update_name
        @error_handler = ErrorHandler.new(profile)
        @circuit_breaker = CircuitBreaker.new
      end

      def call
        @broadcaster = Broadcaster.new(@profile)
        @profile.update(scraping_status: :processing)
        @broadcaster.broadcast_status(:preparing)

        result = @circuit_breaker.call do
          Success(perform_scraping)
        end

        @circuit_breaker.record_success
        result
      rescue CircuitOpenError => e
        @broadcaster.broadcast_error(e.message) if @broadcaster
        @error_handler.handle_circuit_open_error(e)
      rescue Profiles::ProfileNotFoundError => e
        @circuit_breaker.record_failure
        @broadcaster.broadcast_error(e.message) if @broadcaster
        @error_handler.handle_not_found_error(e)
      rescue StandardError => e
        @circuit_breaker.record_failure
        @broadcaster.broadcast_error(e.message) if @broadcaster
        @error_handler.handle_standard_error(e)
      end

      private

      def perform_scraping
        browser_manager = BrowserManager.new

        begin
          @broadcaster.broadcast_status(:navigating)
          browser_manager.navigate_to(@github_url)
          PageValidator.new(browser_manager.browser).validate!

          @broadcaster.broadcast_status(:loading)
          browser_manager.wait_for_contributions(username: @profile.github_username)

          @broadcaster.broadcast_status(:collecting)
          parsed_data = HtmlParser.new(browser_manager.html, update_name: @update_name).parse

          @broadcaster.broadcast_status(:finalizing)
          @profile.update!(
            **parsed_data,
            scraping_status: :completed,
            last_scanned_at: Time.current,
            last_error: nil
          )

          @broadcaster.broadcast_completion
          @profile
        ensure
          browser_manager.quit
        end
      end
    end
  end
end
