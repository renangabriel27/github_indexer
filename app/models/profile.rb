class Profile < ApplicationRecord
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

  validate :validate_github_username_format, if: -> { github_username.present? }

  before_validation :normalize_github_username
  before_save :reset_scraping_data, if: :github_username_changed?

  after_create :enqueue_priority_jobs
  after_update_commit :enqueue_priority_jobs

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

  def normalize_github_username
    return unless github_username.present?
    self.github_username = github_username.strip.downcase
  end

  def validate_github_username_format
    return unless github_username.present?

    if github_username.start_with?('-') || github_username.end_with?('-')
      errors.add(:github_username, "não pode começar ou terminar com hífen")
    end

    if github_username.include?('--')
      errors.add(:github_username, "não pode conter hífens consecutivos")
    end
  end

  def enqueue_priority_jobs
    return unless previously_new_record? || can_rescan?
    enqueue_github_scraper
    enqueue_github_shortener_url
  end

  def enqueue_github_scraper
    update_name = !previously_new_record?
    GithubScraperJob.perform_later(self.id, update_name: update_name)
  end

  def enqueue_github_shortener_url
    UrlShortenerJob.perform_later(self.id)
  end

  def reset_scraping_data
    self.scraping_status = 'pending'
    self.last_scanned_at = nil
    self.last_error = nil
  end
end