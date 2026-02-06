# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShortioUrlShortenerService, '#call' do
  include_context 'ShortioUrlShortenerService setup'

  describe '#call' do
    context 'when request is successful' do
      context 'with status 200' do
        let(:short_url) { 'https://go.short.io/abc123' }
        let(:response_body) do
          {
            'shortURL' => short_url,
            'originalURL' => long_url
          }
        end

        before do
          stub_request(:post, 'https://api.short.io/links/public')
            .with(
              body: {
                originalURL: long_url,
                domain: domain,
                allowDuplicates: false
              }.to_json,
              headers: {
                'Authorization' => api_key,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
              }
            )
            .to_return(
              status: 200,
              body: response_body.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'X-RateLimit-Remaining' => '100'
              }
            )
        end

        it 'returns success with short URL' do
          result = service.call

          expect(result).to eq(
            success: true,
            short_url: short_url,
            original_url: long_url
          )
        end

        it 'makes request with correct body and headers' do
          service.call

          expect(WebMock).to have_requested(:post, 'https://api.short.io/links/public')
            .with(
              body: {
                originalURL: long_url,
                domain: domain,
                allowDuplicates: false
              }.to_json,
              headers: {
                'Authorization' => api_key,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
              }
            )
        end
      end

      context 'with status 201' do
        let(:short_url) { 'https://go.short.io/xyz789' }
        let(:response_body) do
          {
            'shortURL' => short_url,
            'originalURL' => long_url
          }
        end

        before do
          stub_request(:post, 'https://api.short.io/links/public')
            .to_return(
              status: 201,
              body: response_body.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'X-RateLimit-Remaining' => '50'
              }
            )
        end

        it 'returns success with short URL' do
          result = service.call

          expect(result).to eq(
            success: true,
            short_url: short_url,
            original_url: long_url
          )
        end
      end
    end

    context 'when request fails with error status codes' do
      context 'with status 400 (Bad Request)' do
        before do
          stub_request(:post, 'https://api.short.io/links/public')
            .to_return(
              status: 400,
              body: { 'error' => 'Invalid URL format' }.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'X-RateLimit-Remaining' => '100'
              }
            )
        end

        it 'returns error with message from response' do
          result = service.call

          expect(result).to eq(
            success: false,
            error: 'Invalid URL format'
          )
        end
      end

      context 'with status 400 without error message' do
        before do
          stub_request(:post, 'https://api.short.io/links/public')
            .to_return(
              status: 400,
              body: {}.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'X-RateLimit-Remaining' => '100'
              }
            )
        end

        it 'returns default error message' do
          result = service.call

          expect(result).to eq(
            success: false,
            error: 'Bad Request'
          )
        end
      end

      context 'with status 401 (Unauthorized)' do
        before do
          stub_request(:post, 'https://api.short.io/links/public')
            .to_return(
              status: 401,
              body: {}.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'X-RateLimit-Remaining' => '100'
              }
            )
        end

        it 'returns invalid API key error' do
          result = service.call

          expect(result).to eq(
            success: false,
            error: 'Invalid API Key'
          )
        end
      end

      context 'with status 409 (Conflict - Duplicate link)' do
        before do
          stub_request(:post, 'https://api.short.io/links/public')
            .to_return(
              status: 409,
              body: { 'error' => 'Link already exists' }.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'X-RateLimit-Remaining' => '100'
              }
            )
        end

        it 'returns duplicate link error with allow_retry false' do
          result = service.call

          expect(result).to eq(
            success: false,
            error: 'Duplicate link',
            allow_retry: false
          )
        end
      end

      context 'with status 429 (Rate Limit Exceeded)' do
        before do
          stub_request(:post, 'https://api.short.io/links/public')
            .to_return(
              status: 429,
              body: { 'error' => 'Too many requests' }.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'X-RateLimit-Remaining' => '0'
              }
            )
        end

        it 'returns rate limit exceeded error' do
          result = service.call

          expect(result).to eq(
            success: false,
            error: 'Rate limit exceeded'
          )
        end
      end

      context 'with unexpected status code' do
        before do
          stub_request(:post, 'https://api.short.io/links/public')
            .to_return(
              status: 500,
              body: {}.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'X-RateLimit-Remaining' => '100'
              }
            )
        end

        it 'returns unexpected response error' do
          result = service.call

          expect(result).to eq(
            success: false,
            error: 'Unexpected response: 500'
          )
        end
      end
    end

    context 'when response has invalid JSON' do
      before do
        stub_request(:post, 'https://api.short.io/links/public')
          .to_return(
            status: 200,
            body: 'invalid json{',
            headers: {
              'Content-Type' => 'application/json',
              'X-RateLimit-Remaining' => '100'
            }
          )
      end

      it 'returns invalid JSON response error' do
        result = service.call

        expect(result).to eq(
          success: false,
          error: 'Invalid JSON response'
        )
      end
    end

    context 'when request times out' do
      before do
        stub_request(:post, 'https://api.short.io/links/public')
          .to_timeout
      end

      it 'handles timeout error and returns error message' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to include('Timeout')
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(/ShortioUrlShortenerService error/)
        expect(Rails.logger).to receive(:error).with(anything)

        service.call
      end
    end

    context 'when network error occurs' do
      before do
        stub_request(:post, 'https://api.short.io/links/public')
          .to_raise(StandardError.new('Network error'))
      end

      it 'handles network error and returns error message' do
        result = service.call

        expect(result).to eq(
          success: false,
          error: 'Network error'
        )
      end

      it 'logs the error with backtrace' do
        expect(Rails.logger).to receive(:error).with('ShortioUrlShortenerService error: Network error')
        expect(Rails.logger).to receive(:error).with(anything)

        service.call
      end
    end
  end

  describe 'request configuration' do
    before do
      stub_request(:post, 'https://api.short.io/links/public')
        .to_return(
          status: 200,
          body: { 'shortURL' => 'https://go.short.io/test', 'originalURL' => long_url }.to_json,
          headers: { 'Content-Type' => 'application/json', 'X-RateLimit-Remaining' => '100' }
        )
    end

    it 'sends request with allowDuplicates set to false' do
      service.call

      expect(WebMock).to have_requested(:post, 'https://api.short.io/links/public')
        .with(body: hash_including(allowDuplicates: false))
    end

    it 'sends request with correct originalURL' do
      service.call

      expect(WebMock).to have_requested(:post, 'https://api.short.io/links/public')
        .with(body: hash_including(originalURL: long_url))
    end
  end
end

