class Profile < ApplicationRecord
  validates :name, presence: true, length: { in: 2..100 }

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
end
