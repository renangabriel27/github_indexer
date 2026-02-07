# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found, layout: "application" }
      format.json { render json: { error: { code: "not_found", message: "Page not found" } }, status: :not_found }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render "errors/unprocessable_entity", status: :unprocessable_entity, layout: "application" }
      format.json { render json: { error: { code: "unprocessable_entity", message: "Unprocessable entity" } }, status: :unprocessable_entity }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render "errors/internal_server_error", status: :internal_server_error, layout: "application" }
      format.json { render json: { error: { code: "internal_server_error", message: "Internal server error" } }, status: :internal_server_error }
    end
  end
end
