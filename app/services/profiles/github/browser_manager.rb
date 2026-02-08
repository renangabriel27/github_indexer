# frozen_string_literal: true

module Profiles
  module Github
    class BrowserManager
      BROWSER_TIMEOUT = 30
      ELEMENT_WAIT_TIMEOUT = 10

      attr_reader :browser

      def initialize
        @browser = setup_browser
      end

      def navigate_to(url)
        browser.go_to(url)
      end

      def wait_for_contributions(username: nil)
        found = wait_for_element(Selectors::CONTRIBUTION_WAIT_SELECTOR)
        unless found
          if username
            Rails.logger.warn("Contribuições não carregadas a tempo para #{username}, continuando parsing...")
          else
            Rails.logger.warn("Contribuições não carregadas, continuando o parsing...")
          end
        end
        found
      end

      def html
        browser.body
      end

      def quit
        browser&.quit
      end

      private

      def setup_browser
        browser_path = ENV.fetch("CHROME_BIN", "/usr/bin/chromium")

        Ferrum::Browser.new(
          headless: true,
          timeout: BROWSER_TIMEOUT,
          browser_path: browser_path,
          browser_options: {
            'no-sandbox': nil,
            'disable-dev-shm-usage': nil,
            'disable-gpu': nil,
            'disable-software-rasterizer': nil
          }
        )
      end

      def wait_for_element(selector, timeout: ELEMENT_WAIT_TIMEOUT)
        elapsed = 0
        interval = 0.5

        while elapsed < timeout
          return true if browser.at_css(selector)
          sleep interval
          elapsed += interval
        end

        Rails.logger.warn("Element #{selector} not found after #{timeout}s")
        false
      end
    end
  end
end
