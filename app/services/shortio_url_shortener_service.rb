class ShortioUrlShortenerService
  include HTTParty
  base_uri 'https://api.short.io/links'

  TIMEOUT = 5
  MAX_RETRIES = 3

  def initialize(long_url)
    @long_url = long_url
    @api_key = ENV.fetch('SHORTIO_API_KEY')
    @domain = ENV.fetch('SHORTIO_DOMAIN', 'go.short.io')
  end

  def call
    validate_config!

    result = shorten_with_retry
    parse_response(result)
  rescue StandardError => e
    handle_error(e)
  end

  private

  def validate_config!
    raise 'SHORTIO_API_KEY not configured' if @api_key.blank?
  end

  def shorten_with_retry
    retries = 0

    begin
      make_request
    rescue Net::OpenTimeout, Net::ReadTimeout
      retries += 1
      if retries < MAX_RETRIES
        sleep(2 ** retries) # Backoff: 2s, 4s, 8s
        retry
      else
        raise 'Timeout after retries'
      end
    end
  end

  def make_request
    response = self.class.post(
      '/public',
      body: request_body.to_json,
      headers: headers,
      timeout: TIMEOUT
    )

    check_rate_limit(response)
    response
  end

  def request_body
    {
      originalURL: @long_url,
      domain: @domain,
      allowDuplicates: false
    }
  end

  def headers
    {
      'Authorization' => @api_key,
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  def check_rate_limit(response)
    remaining = response.headers['X-RateLimit-Remaining'].to_i

    if remaining < 10
      Rails.logger.warn("Short.io rate limit low: #{remaining} remaining")
    end
  end

  def parse_response(response)
    case response.code
    when 200, 201
      data = response.parsed_response
      {
        success: true,
        short_url: data['shortURL'],
        original_url: data['originalURL']
      }
    when 400
      error_message = response.parsed_response['error'] || 'Bad Request'
      { success: false, error: error_message }
    when 401
      { success: false, error: 'Invalid API Key' }
    when 409
      # Link já existe
      { success: false, error: 'Duplicate link', allow_retry: false }
    when 429
      { success: false, error: 'Rate limit exceeded' }
    else
      { success: false, error: "Unexpected response: #{response.code}" }
    end
  rescue JSON::ParserError
    { success: false, error: 'Invalid JSON response' }
  end

  def handle_error(error)
    Rails.logger.error("ShortioUrlShortenerService error: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n"))

    { success: false, error: error.message }
  end
end