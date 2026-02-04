module Api::V1
  class BaseController < ActionController::API
    include Pagy::Method

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Not found" }, status: :not_found
    end
  end
end
