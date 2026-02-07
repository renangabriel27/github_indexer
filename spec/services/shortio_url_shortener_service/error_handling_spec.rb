# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShortioUrlShortenerService, '#call - error handling' do
  include_context 'ShortioUrlShortenerService setup'

  describe 'HTTP error status codes' do
    it 'returns error for status 400 with message from response' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 400,
          body: { 'error' => 'Invalid URL format' }.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
        )

      result = service.call

      expect(result).to be_failure
      expect(result.failure[:error]).to eq(:unknown)
      expect(result.failure[:message]).to eq('Unexpected response: 400')
      expect(result.failure[:retryable]).to be false
    end

    it 'returns error for status 401 Unauthorized' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 401,
          body: {}.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
        )

      result = service.call

      expect(result).to be_failure
      expect(result.failure[:error]).to eq(:authentication_failed)
      expect(result.failure[:message]).to eq('Invalid API Key')
      expect(result.failure[:retryable]).to be false
    end

    it 'returns error for status 429 Rate Limit Exceeded' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 429,
          body: { 'error' => 'Too many requests' }.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '0' }
        )

      result = service.call

      expect(result).to be_failure
      expect(result.failure[:error]).to eq(:rate_limit_exceeded)
      expect(result.failure[:message]).to eq('Rate limit exceeded')
      expect(result.failure[:retryable]).to be true
    end

    it 'returns error for unexpected status code' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 500,
          body: {}.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
        )

      result = service.call

      expect(result).to be_failure
      expect(result.failure[:error]).to eq(:unknown)
      expect(result.failure[:message]).to eq('Unexpected response: 500')
      expect(result.failure[:retryable]).to be false
    end
  end

  describe 'response parsing errors' do
    it 'returns error when response has invalid JSON' do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 200,
          body: 'invalid json{',
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
        )

      result = service.call

      expect(result).to be_failure
      expect(result.failure[:error]).to eq(:unknown)
      expect(result.failure[:retryable]).to be false
    end
  end

  describe 'network errors' do
    it 'handles timeout error' do
      stub_request(:post, 'https://api.short.io/links/public').to_timeout

      result = service.call

      expect(result).to be_failure
      expect(result.failure[:error]).to eq(:timeout)
      expect(result.failure[:message]).to eq('Request timeout')
      expect(result.failure[:retryable]).to be true
    end
  end
end
