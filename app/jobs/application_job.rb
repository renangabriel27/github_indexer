# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::Deadlocked

  discard_on ActiveJob::DeserializationError

  private

  def find_record_safely(klass, id)
    record = klass.find_by(id: id)

    unless record
      log_event(:not_found, id: id, model: klass.name)
    end

    record
  end

  def log_event(event, **details)
    job_name = self.class.name
    message = build_log_message(job_name, event, details)

    case event
    when :started, :success
      Rails.logger.info(message)
    when :not_found
      Rails.logger.warn(message)
    when :failed
      Rails.logger.error(message)
    end
  end

  def handle_service_result(result, profile_id:)
    if result.success?
      yield result.value! if block_given?
      log_event(:success, profile_id: profile_id, data: result.value!)
    else
      error = result.failure
      log_event(:failed, profile_id: profile_id, error: error[:error], message: error[:message])

      raise StandardError, error[:message] if error[:retryable]
    end
  end

  def build_log_message(job_name, event, details)
    parts = ["[#{job_name}]", event.to_s]

    details.each do |key, value|
      parts << "#{key}=#{value}" if value.present?
    end

    parts.join(" ")
  end
end
