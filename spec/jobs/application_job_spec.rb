# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  include Dry::Monads::Result::Mixin

  let(:test_job_class) do
    Class.new(ApplicationJob) do
      def perform; end

      def public_find_record_safely(klass, id)
        find_record_safely(klass, id)
      end

      def public_handle_service_result(result, profile_id:, &block)
        handle_service_result(result, profile_id: profile_id, &block)
      end
    end
  end

  let(:job_instance) { test_job_class.new }

  describe "#find_record_safely" do
    let!(:profile) { create(:profile) }

    it "returns the record when it exists" do
      expect(job_instance.public_find_record_safely(Profile, profile.id)).to eq(profile)
    end

    it "returns nil and logs warning when record does not exist" do
      expect(Rails.logger).to receive(:warn).with(/not_found.*id=999999/)
      expect(job_instance.public_find_record_safely(Profile, 999999)).to be_nil
    end
  end

  describe "#handle_service_result" do
    let(:profile_id) { 1 }

    context "when result is success" do
      let(:result) { Success({ data: "test_data" }) }

      it "logs success and yields the value" do
        allow(Rails.logger).to receive(:info)
        yielded_value = nil

        job_instance.public_handle_service_result(result, profile_id: profile_id) { |v| yielded_value = v }

        expect(yielded_value).to eq({ data: "test_data" })
      end
    end

    context "when result is failure" do
      it "raises StandardError for retryable errors" do
        result = Failure(error: :timeout, message: "Request timeout", retryable: true)
        allow(Rails.logger).to receive(:error)

        expect { job_instance.public_handle_service_result(result, profile_id: profile_id) }
          .to raise_error(StandardError, "Request timeout")
      end

      it "does not raise for non-retryable errors" do
        result = Failure(error: :invalid_data, message: "Invalid data", retryable: false)
        allow(Rails.logger).to receive(:error)

        expect { job_instance.public_handle_service_result(result, profile_id: profile_id) }
          .not_to raise_error
      end
    end
  end
end
