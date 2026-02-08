# frozen_string_literal: true

module Api::V1
  class ProfilesController < BaseController
    include Paginatable

    def index
      profiles = ProfilesFilterQuery.call(filter_params)
      @pagy, @profiles = pagy(:offset, profiles, offset: calculate_offset, limit: per_page(default: 10))

      render json: {
        data: Api::V1::ProfileSerializer.render_as_hash(@profiles),
        meta: pagination_meta(@pagy)
      }
    end

    def show
      @profile = Profile.find(params[:id])
      render json: {
        data: Api::V1::ProfileSerializer.render_as_hash(@profile)
      }
    end

    private

    def filter_params
      {
        q: params[:search] || params[:q],
        status: params[:status],
        order: params[:order]
      }
    end
  end
end
