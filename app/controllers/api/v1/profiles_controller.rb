module Api::V1
  class ProfilesController < BaseController
    def index
      profiles = filter_profiles
      offset_value = calculate_offset

      @pagy, @profiles = pagy(:offset, profiles, offset: calculate_offset, limit: per_page)

      render json: {
        data: ProfileSerializer.render_as_hash(@profiles),
        meta: pagination_meta(@pagy)
      }
    end

    def show
      @profile = Profile.find(params[:id])
      render json: { data: ProfileSerializer.render_as_hash(@profile) }
    end

    private

    def calculate_offset
      return params[:offset].to_i if params[:offset].present?

      page = params[:page].to_i
      page = 1 if page < 1

      (page - 1) * per_page
    end

    def filter_profiles
      scope = Profile.all
      search_query = params[:search] || params[:q]
      scope = scope.search(search_query) if search_query.present?
      scope.order(created_at: :desc)
    end

    def per_page
      requested = params[:per_page].to_i
      requested.positive? ? [ requested, 100 ].min : 10
    end

    def pagination_meta(pagy)
      {
        current_page: pagy.page,
        per_page: pagy.limit,
        total_pages: pagy.pages,
        total_count: pagy.count
      }
    end
  end
end
