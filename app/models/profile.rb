class Profile < ApplicationRecord
  validates :name, presence: true, length: { in: 2..100 }
  validates :github_url,
            presence: true,
            format: { with: %r{\Ahttps?://(?:www\.)?github\.com/[\w-]+/?\z} },
            uniqueness: { case_insensitive: false }

  before_validation :normalize_github_url

  enum :scraping_status, {
    pending: 'pending',
    processing: 'processing',
    completed: 'completed',
    failed: 'failed'
  }

  private

  def normalize_github_url
    return if github_url.blank?
    self.github_url = github_url.strip
                                .sub(%r{\Agithub\.com}, 'https://github.com')
                                .sub(%r{/+\z}, '')
  end
end
