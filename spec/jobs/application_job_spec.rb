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

      def public_log_event(event, **details)
        log_event(event, **details)
      end

      def public_handle_service_result(result, profile_id:, &block)
        handle_service_result(result, profile_id: profile_id, &block)
      end

      def public_build_log_message(job_name, event, details)
        build_log_message(job_name, event, details)
      end
    end
  end

  let(:job_instance) { test_job_class.new }

  describe "#find_record_safely" do
    let!(:profile) { create(:profile) }

    context "when record exists" do
      it "returns the record" do
        result = job_instance.public_find_record_safely(Profile, profile.id)
        expect(result).to eq(profile)
      end

      it "does not log anything" do
        expect(Rails.logger).not_to receive(:warn)
        job_instance.public_find_record_safely(Profile, profile.id)
      end
    end

    context "when record does not exist" do
      it "returns nil" do
        result = job_instance.public_find_record_safely(Profile, 999999)
        expect(result).to be_nil
      end

      it "logs a warning with model and id" do
        expect(Rails.logger).to receive(:warn).with(/not_found.*id=999999.*model=Profile/)
        job_instance.public_find_record_safely(Profile, 999999)
      end
    end
  end

  describe "#log_event" do
    it "logs info for :started event" do
      expect(Rails.logger).to receive(:info).with(/started/)
      job_instance.public_log_event(:started, profile_id: 1)
    end

    it "logs info for :success event" do
      expect(Rails.logger).to receive(:info).with(/success/)
      job_instance.public_log_event(:success, profile_id: 1)
    end

    it "logs warn for :not_found event" do
      expect(Rails.logger).to receive(:warn).with(/not_found/)
      job_instance.public_log_event(:not_found, profile_id: 1)
    end

    it "logs error for :failed event" do
      expect(Rails.logger).to receive(:error).with(/failed/)
      job_instance.public_log_event(:failed, profile_id: 1, error: "timeout")
    end

    it "includes job name in message" do
      expect(Rails.logger).to receive(:info).with(/\[#{test_job_class.name}\]/)
      job_instance.public_log_event(:started, profile_id: 1)
    end

    it "includes details in message" do
      expect(Rails.logger).to receive(:info).with(/profile_id=1.*update_name=true/)
      job_instance.public_log_event(:started, profile_id: 1, update_name: true)
    end
  end

  describe "#handle_service_result" do
    let(:profile_id) { 1 }

    context "when result is success" do
      let(:result) { Success({ data: "test_data" }) }

      it "logs success" do
        expect(Rails.logger).to receive(:info).with(/success.*profile_id=#{profile_id}/)
        job_instance.public_handle_service_result(result, profile_id: profile_id)
      end

      it "yields the value to the block if given" do
        yielded_value = nil
        job_instance.public_handle_service_result(result, profile_id: profile_id) do |value|
          yielded_value = value
        end
        expect(yielded_value).to eq({ data: "test_data" })
      end

      it "does not raise an error" do
        expect do
          job_instance.public_handle_service_result(result, profile_id: profile_id)
        end.not_to raise_error
      end
    end

    context "when result is failure with retryable error" do
      let(:result) do
        Failure(
          error: :timeout,
          message: "Request timeout",
          retryable: true
        )
      end

      it "logs the failure" do
        expect(Rails.logger).to receive(:error).with(/failed.*profile_id=#{profile_id}.*error=timeout/)

        expect do
          job_instance.public_handle_service_result(result, profile_id: profile_id)
        end.to raise_error(StandardError)
      end

      it "raises StandardError for retry" do
        allow(Rails.logger).to receive(:error)

        expect do
          job_instance.public_handle_service_result(result, profile_id: profile_id)
        end.to raise_error(StandardError, "Request timeout")
      end
    end

    context "when result is failure with non-retryable error" do
      let(:result) do
        Failure(
          error: :invalid_data,
          message: "Invalid profile data",
          retryable: false
        )
      end

      it "logs the failure" do
        expect(Rails.logger).to receive(:error).with(/failed.*profile_id=#{profile_id}.*error=invalid_data/)
        job_instance.public_handle_service_result(result, profile_id: profile_id)
      end

      it "does not raise an error" do
        allow(Rails.logger).to receive(:error)

        expect do
          job_instance.public_handle_service_result(result, profile_id: profile_id)
        end.not_to raise_error
      end
    end
  end

  describe "#build_log_message" do
    it "includes job name in brackets" do
      message = job_instance.public_build_log_message("TestJob", :started, {})
      expect(message).to start_with("[TestJob]")
    end

    it "includes event type" do
      message = job_instance.public_build_log_message("TestJob", :started, {})
      expect(message).to include("started")
    end

    it "includes all details as key=value pairs" do
      message = job_instance.public_build_log_message(
        "TestJob",
        :success,
        { profile_id: 1, update_name: true }
      )
      expect(message).to include("profile_id=1")
      expect(message).to include("update_name=true")
    end

    it "skips details with blank values" do
      message = job_instance.public_build_log_message(
        "TestJob",
        :started,
        { profile_id: 1, data: nil }
      )
      expect(message).to include("profile_id=1")
      expect(message).not_to include("data=")
    end
  end
end
