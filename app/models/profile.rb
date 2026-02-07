class Profile < ApplicationRecord
  include Searchable

  validates :name, presence: true
  validates :github_username, presence: true
  validates :github_username, uniqueness: { case_sensitive: false }

  validates :github_username, format: {
    with: /\A[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\z/,
    message: "inválido. Use apenas letras, números e hífens"
  }, if: -> { github_username.present? }

  validates :github_username, length: {
    maximum: 39,
    message: "deve ter no máximo 39 caracteres"
  }, if: -> { github_username.present? }

  validates :github_username, github_username_format: true, if: -> { github_username.present? }

  before_validation :normalize_github_username

  enum :scraping_status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }

  def can_rescan?
    last_scanned_at.nil? || last_scanned_at < 5.minutes.ago
  end

  private

  def normalize_github_username
    return unless github_username.present?
    self.github_username = github_username.strip.downcase
  end
end
