# frozen_string_literal: true

# Base class for services that organize work into discrete steps.
# Each step receives a context hash and returns a Success/Failure monad.
# Steps are executed in sequence, and the pipeline stops on the first failure.
#
# Example:
#   class MyService < OrganizedService
#     def initialize(input)
#       @input = input
#     end
#
#     private
#
#     def context
#       { input: @input, result: {} }
#     end
#
#     def steps
#       [:step_one, :step_two, :step_three]
#     end
#
#     def step_one(ctx)
#       ctx[:result][:foo] = "bar"
#       Success(ctx)
#     end
#   end
class OrganizedService < ApplicationService
  def call
    steps.reduce(Success(context)) do |result, step|
      result.bind { |ctx| run_step(step, ctx) }
    end
  end

  private

  def steps
    raise NotImplementedError, "#{self.class} must define #steps method"
  end

  def context
    raise NotImplementedError, "#{self.class} must define #context method"
  end

  def run_step(step, context)
    send(step, context)
  end
end
