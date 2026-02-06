class ApplicationController < ActionController::Base
  include Pagy::Method
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :render_unprocessable_entity

  private

  def render_not_found
    render "errors/not_found", status: :not_found, layout: "application"
  end

  def render_unprocessable_entity
    render "errors/unprocessable_entity", status: :unprocessable_entity, layout: "application"
  end
end
