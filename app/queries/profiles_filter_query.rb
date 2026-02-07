# frozen_string_literal: true

class ProfilesFilterQuery
  def self.call(params = {})
    new(params).call
  end

  def initialize(params = {})
    @params = params
  end

  def call
    scope = Profile.all
    scope = apply_search(scope)
    scope = apply_status_filter(scope)
    apply_ordering(scope)
  end

  private

  attr_reader :params

  def apply_search(scope)
    search_query = params[:q]
    return scope unless search_query.present?

    scope.search(search_query)
  end

  def apply_status_filter(scope)
    return scope unless params[:status].present?

    scope.where(scraping_status: params[:status])
  end

  def apply_ordering(scope)
    case params[:order]
    when "name"
      scope.order(name: :asc)
    when "followers"
      scope.order(followers: :desc)
    else
      scope.order(created_at: :desc)
    end
  end
end
