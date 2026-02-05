module Profiles
  class ScraperService < ApplicationService
    GITHUB_HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
      "Accept-Language" => "en-US,en;q=0.9"
    }.freeze

    def initialize(profile, update_name: false)
      @profile = profile
      @github_url = "https://www.github.com/#{profile.github_username}"
      @update_name = update_name
    end

    def call
      @profile.update(scraping_status: :processing)
      # return Failure("Failed to fetch GitHub page") unless response&.success?
      Success(fetch_profile_with_js)
    rescue StandardError => e
      @profile.update(
        scraping_status: :failed,
        last_error: e.message,
        last_scanned_at: Time.current
      )
      Failure(e.message)
    end

    private

    def fetch_profile_with_js
      @browser = setup_browser

      @browser.go_to(@github_url)
      wait_for_contributions

      html = @browser.body
      parsed_data = parse_page(html)
      parsed_data.delete(:name) unless @update_name

      @profile.update!(parsed_data.merge(
        scraping_status: :completed,
        last_scanned_at: Time.current,
        last_error: nil
      ))

      @profile
    ensure
      @browser&.quit
    end

    def setup_browser
      Ferrum::Browser.new(
        headless: true,
        timeout: 30,
        browser_options: {
          'no-sandbox': nil,
          'disable-dev-shm-usage': nil
        }
      )
    end

    def wait_for_contributions
      wait_for_element(@browser, 'h2[id*="contribution"]', timeout: 10)
    end

    def parse_page(html)
      doc = Nokogiri::HTML(html)

      {
        name: extract_name(doc),
        github_username: extract_username(doc),
        followers: extract_followers(doc),
        following: extract_following(doc),
        stars: extract_stars(doc),
        contributions_last_year: extract_contributions(doc),
        avatar_url: extract_avatar(doc),
        location: extract_location(doc),
        organizations: extract_organizations(doc)
      }
    end

    def extract_name(doc)
      name = doc.at_css('[itemprop="name"]')&.text&.strip
      name || doc.at_css(".p-name")&.text&.strip
    end

    def extract_username(doc)
      username = doc.at_css('[itemprop="additionalName"]')&.text&.strip
      username || doc.at_css(".vcard-username")&.text&.strip
    end

    def extract_followers(doc)
      link = doc.at_css('a[href*="tab=followers"]')
      return 0 unless link

      number_text = link.at_css(".text-bold")&.text&.strip
      parse_number(number_text)
    end

    def extract_following(doc)
      link = doc.at_css('a[href*="tab=following"]')
      return 0 unless link

      number_text = link.at_css(".text-bold")&.text&.strip
      parse_number(number_text)
    end

    def extract_stars(doc)
      link = doc.at_css('a[href*="tab=stars"]')
      return 0 unless link

      counter = link.at_css('[data-view-component="true"][class*="Counter"]')&.text&.strip
      counter ||= link.text.scan(/\d+/).first

      parse_number(counter)
    end

    def extract_contributions(doc)
      node = doc.at_css('h2#js-contribution-activity-description, h2[id*="contribution"]')
      return 0 unless node

      text = node.text.gsub(/\s+/, " ").strip
      number = text[/[\d,.]+/]

      return 0 unless number
      number.delete(".,").to_i
    end

    def extract_avatar(doc)
      avatar = doc.at_css(".avatar-user")&.[]("src")
      avatar ||= doc.at_css('meta[property="og:image"]')&.[]("content")

      avatar = normalize_url(avatar)
      avatar&.gsub(/s=64&/, "")
    end

    def extract_location(doc)
      location_item = doc.at_css('[itemprop="homeLocation"]')
      return nil unless location_item
      location_item.at_css(".p-label")&.text&.strip
    end

    def extract_organizations(doc)
      orgs = []

      doc.css('a[itemprop="follows"]').each do |org_link|
        org_name = org_link["aria-label"]
        org_name ||= org_link.at_css("img")&.[]("alt")&.sub("@", "")

        orgs << org_name if org_name.present?
      end

      orgs.uniq
    end

    def wait_for_element(browser, selector, timeout: 10)
      elapsed = 0
      interval = 0.5

      while elapsed < timeout
        return true if browser.at_css(selector)
        sleep interval
        elapsed += interval
      end

      Rails.logger.warn("Elemento #{selector} não encontrado após #{timeout}s")
      false
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
