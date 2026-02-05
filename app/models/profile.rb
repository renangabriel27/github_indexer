class Profile < ApplicationRecord
  attr_accessor :github_url

  validates :name, presence: true
  validate :validate_github_url, if: -> { github_url.present? }

  enum :scraping_status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }

  scope :search, ->(q) {
    return all if q.blank?
    where("name ILIKE :q OR github_username ILIKE :q OR location ILIKE :q", q: "%#{q}%")
  }

  def can_rescan?
    last_scanned_at.nil? || last_scanned_at < 5.minutes.ago
  end

  private

  def validate_github_url
    return unless github_url.present?

    normalized_url = github_url.strip.chomp('/')

    unless normalized_url.match?(/\Ahttps?:\/\/(www\.)?github\.com\/[\w-]+\/?\z/i)
      errors.add(:github_url, "deve ser uma URL válida do GitHub (ex: https://github.com/username)")
    end
  end
end