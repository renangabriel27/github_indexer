# frozen_string_literal: true

require "rails_helper"
require "mock_redis"

RSpec.describe Profiles::Github::CircuitBreaker do
  let(:redis) { MockRedis.new }
  let(:circuit_breaker) { described_class.new(redis: redis) }

  before do
    circuit_breaker.reset
  end

  after do
    circuit_breaker.reset
  end

  describe "#call" do
    context "when circuit is closed" do
      it "executes the block" do
        result = circuit_breaker.call { "success" }
        expect(result).to eq("success")
      end
    end

    context "when circuit is open" do
      before do
        described_class::MAX_FAILURES.times { circuit_breaker.record_failure }
      end

      it "raises CircuitOpenError" do
        expect {
          circuit_breaker.call { "should not execute" }
        }.to raise_error(Profiles::Github::CircuitOpenError, /Circuit breaker is open/)
      end

      it "includes retry time in error message" do
        expect {
          circuit_breaker.call { "should not execute" }
        }.to raise_error(Profiles::Github::CircuitOpenError, /Retry after \d+s/)
      end
    end

    context "when circuit is half-open" do
      before do
        described_class::MAX_FAILURES.times { circuit_breaker.record_failure }
        redis.set("github_scraper_circuit_breaker:opened_at", Time.current.to_i - described_class::TIMEOUT - 1)
      end

      it "allows one attempt" do
        result = circuit_breaker.call { "testing" }
        expect(result).to eq("testing")
      end
    end
  end

  describe "#record_success" do
    context "when circuit is closed" do
      it "resets failure count" do
        2.times { circuit_breaker.record_failure }
        expect(circuit_breaker.failure_count).to eq(2)

        circuit_breaker.record_success
        expect(circuit_breaker.failure_count).to eq(0)
      end
    end

    context "when circuit is half-open" do
      before do
        described_class::MAX_FAILURES.times { circuit_breaker.record_failure }
        redis.set("github_scraper_circuit_breaker:opened_at", Time.current.to_i - described_class::TIMEOUT - 1)
        circuit_breaker.call { "success" }
      end

      it "transitions to closed state" do
        circuit_breaker.record_success
        expect(circuit_breaker.current_state).to eq("closed")
      end

      it "resets failure count" do
        circuit_breaker.record_success
        expect(circuit_breaker.failure_count).to eq(0)
      end
    end
  end

  describe "#record_failure" do
    it "increments failure count" do
      expect {
        circuit_breaker.record_failure
      }.to change { circuit_breaker.failure_count }.from(0).to(1)
    end

    context "when reaching max failures" do
      it "opens the circuit" do
        described_class::MAX_FAILURES.times { circuit_breaker.record_failure }
        expect(circuit_breaker.current_state).to eq("open")
      end
    end
  end

  describe "#current_state" do
    it "returns closed by default" do
      expect(circuit_breaker.current_state).to eq("closed")
    end

    it "returns open after max failures" do
      described_class::MAX_FAILURES.times { circuit_breaker.record_failure }
      expect(circuit_breaker.current_state).to eq("open")
    end
  end

  describe "#failure_count" do
    it "returns 0 by default" do
      expect(circuit_breaker.failure_count).to eq(0)
    end

    it "tracks failures correctly" do
      3.times { circuit_breaker.record_failure }
      expect(circuit_breaker.failure_count).to eq(3)
    end
  end

  describe "#reset" do
    before do
      3.times { circuit_breaker.record_failure }
    end

    it "clears all circuit breaker data" do
      circuit_breaker.reset
      expect(circuit_breaker.current_state).to eq("closed")
      expect(circuit_breaker.failure_count).to eq(0)
    end
  end
end
