# frozen_string_literal: true

class GithubUsernameFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    validate_hyphen_placement(record, attribute, value)
    validate_consecutive_hyphens(record, attribute, value)
  end

  private

  def validate_hyphen_placement(record, attribute, value)
    return unless value.start_with?("-") || value.end_with?("-")

    record.errors.add(attribute, :invalid_hyphen_placement,
                      message: "não pode começar ou terminar com hífen")
  end

  def validate_consecutive_hyphens(record, attribute, value)
    return unless value.include?("--")

    record.errors.add(attribute, :consecutive_hyphens,
                      message: "não pode conter hífens consecutivos")
  end
end
