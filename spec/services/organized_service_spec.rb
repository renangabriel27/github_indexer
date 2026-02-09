# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizedService do
  # Dummy service for testing the base class
  class TestOrganizedService < OrganizedService
    def initialize(value)
      @value = value
    end

    private

    def context
      { value: @value, result: [] }
    end

    def steps
      [:add_one, :multiply_by_two, :subtract_three]
    end

    def add_one(ctx)
      ctx[:result] << "add_one"
      ctx[:value] += 1
      Success(ctx)
    end

    def multiply_by_two(ctx)
      ctx[:result] << "multiply_by_two"
      ctx[:value] *= 2
      Success(ctx)
    end

    def subtract_three(ctx)
      ctx[:result] << "subtract_three"
      ctx[:value] -= 3
      Success(ctx)
    end
  end

  # Service that fails in the middle
  class FailingOrganizedService < OrganizedService
    def initialize(fail_at_step)
      @fail_at_step = fail_at_step
    end

    private

    def context
      { executed_steps: [] }
    end

    def steps
      [:step_one, :step_two, :step_three]
    end

    def step_one(ctx)
      ctx[:executed_steps] << :step_one
      return Failure(:failed_at_step_one) if @fail_at_step == :step_one
      Success(ctx)
    end

    def step_two(ctx)
      ctx[:executed_steps] << :step_two
      return Failure(:failed_at_step_two) if @fail_at_step == :step_two
      Success(ctx)
    end

    def step_three(ctx)
      ctx[:executed_steps] << :step_three
      return Failure(:failed_at_step_three) if @fail_at_step == :step_three
      Success(ctx)
    end
  end

  describe "#call" do
    context "when all steps succeed" do
      it "executes all steps in order" do
        result = TestOrganizedService.call(5)

        expect(result).to be_success
        expect(result.value![:result]).to eq(["add_one", "multiply_by_two", "subtract_three"])
      end

      it "transforms context through the pipeline" do
        result = TestOrganizedService.call(5)

        expect(result).to be_success
        expect(result.value![:value]).to eq(9)
      end
    end

    context "when a step fails" do
      it "stops execution at the first failure" do
        result = FailingOrganizedService.call(:step_two)

        expect(result).to be_failure
        expect(result.failure).to eq(:failed_at_step_two)
      end

      it "does not execute subsequent steps after failure" do
        result = FailingOrganizedService.call(:step_two)

        ctx = result.failure
        service = FailingOrganizedService.new(:step_two)
        service.call

        expect(result).to be_failure
      end

      it "executes steps before the failing step" do
        result = FailingOrganizedService.call(:step_three)

        expect(result).to be_failure
        expect(result.failure).to eq(:failed_at_step_three)
      end
    end
  end

  describe "required method implementations" do
    class IncompleteService < OrganizedService
    end

    it "raises NotImplementedError if #steps is not defined" do
      service = IncompleteService.new

      expect { service.send(:steps) }.to raise_error(
        NotImplementedError,
        "IncompleteService must define #steps method"
      )
    end

    it "raises NotImplementedError if #context is not defined" do
      service = IncompleteService.new

      expect { service.send(:context) }.to raise_error(
        NotImplementedError,
        "IncompleteService must define #context method"
      )
    end
  end

  describe ".call class method" do
    it "creates instance and calls #call" do
      result = TestOrganizedService.call(10)

      expect(result).to be_success
      expect(result.value![:value]).to eq(19)
    end
  end
end
