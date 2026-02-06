module Searchable
  extend ActiveSupport::Concern

  SEARCHABLE_TEXT_FIELDS = %w[name github_username short_github_url avatar_url location].freeze

  included do
    scope :search, ->(query) { search_by_query(query) }
  end

  class_methods do
    def search_by_query(query)
      return all if query.blank?

      normalized_query = normalize_search_query(query)
      conditions = build_search_conditions
      where(conditions.join(" OR "), q: "%#{normalized_query}%")
    end

    private

    def normalize_search_query(query)
      query.to_s.strip
    end

    def build_search_conditions
      [
        text_fields_search_condition,
        organizations_search_condition
      ]
    end

    def text_fields_search_condition
      conditions = SEARCHABLE_TEXT_FIELDS.map { |field| "#{field} ILIKE :q" }
      "(#{conditions.join(' OR ')})"
    end

    def organizations_search_condition
      "organizations::text ILIKE :q"
    end
  end
end
