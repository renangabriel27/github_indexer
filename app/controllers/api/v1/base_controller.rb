# frozen_string_literal: true

module Api::V1
  class BaseController < ActionController::API
    include Pagy::Method

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

    private

    def not_found(exception = nil)
      render_error(
        code: "not_found",
        message: exception&.message || "Record not found",
        status: :not_found
      )
    end

    def bad_request(exception)
      render_error(
        code: "bad_request",
        message: exception.message,
        status: :bad_request
      )
    end

    def unprocessable_entity(exception)
      render_error(
        code: "unprocessable_entity",
        message: exception.message,
        status: :unprocessable_entity
      )
    end

    def render_error(code:, message:, status: :unprocessable_entity, details: nil)
      response = {
        error: {
          code: code,
          message: message
        }
      }
      response[:error][:details] = details if details.present?

      render json: response, status: status
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
