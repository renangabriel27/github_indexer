# frozen_string_literal: true

module Profiles
  module Github
    class CircuitBreaker
      MAX_FAILURES = 5
      TIMEOUT = 60
      HALF_OPEN_ATTEMPTS = 1

      STATE_CLOSED = "closed"
      STATE_OPEN = "open"
      STATE_HALF_OPEN = "half_open"

      def initialize(redis: Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")))
        @redis = redis
        @key_prefix = "github_scraper_circuit_breaker"
      end

      def call
        case current_state
        when STATE_OPEN
          if timeout_expired?
            transition_to_half_open
            yield
          else
            raise CircuitOpenError, "Circuit breaker is open. Retry after #{time_until_retry}s"
          end
        when STATE_HALF_OPEN, STATE_CLOSED
          yield
        end
      end

      def record_success
        case current_state
        when STATE_HALF_OPEN
          reset
        when STATE_CLOSED
          reset_failure_count
        end
      end

      def record_failure
        increment_failures

        if failure_count >= MAX_FAILURES
          open_circuit
        end
      end

      def current_state
        @redis.get(state_key) || STATE_CLOSED
      end

      def failure_count
        @redis.get(failure_key).to_i
      end

      def reset
        @redis.del(state_key, failure_key, opened_at_key)
      end

      private

      def transition_to_half_open
        @redis.set(state_key, STATE_HALF_OPEN)
      end

      def open_circuit
        @redis.set(state_key, STATE_OPEN)
        @redis.set(opened_at_key, Time.current.to_i)
      end

      def timeout_expired?
        opened_at = @redis.get(opened_at_key).to_i
        return true if opened_at.zero?

        (Time.current.to_i - opened_at) >= TIMEOUT
      end

      def time_until_retry
        opened_at = @redis.get(opened_at_key).to_i
        return 0 if opened_at.zero?

        remaining = TIMEOUT - (Time.current.to_i - opened_at)
        [ remaining, 0 ].max
      end

      def increment_failures
        @redis.incr(failure_key)
      end

      def reset_failure_count
        @redis.set(failure_key, 0)
      end

      def state_key
        "#{@key_prefix}:state"
      end

      def failure_key
        "#{@key_prefix}:failures"
      end

      def opened_at_key
        "#{@key_prefix}:opened_at"
      end
    end

    class CircuitOpenError < StandardError; end
  end
end
