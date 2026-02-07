# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Method

  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :render_unprocessable_entity

  private

  def render_not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found, layout: "application" }
      format.json { render json: { error: { code: "not_found", message: "Record not found" } }, status: :not_found }
    end
  end

  def render_unprocessable_entity
    respond_to do |format|
      format.html { render "errors/unprocessable_entity", status: :unprocessable_entity, layout: "application" }
      format.json { render json: { error: { code: "unprocessable_entity", message: "Invalid request" } }, status: :unprocessable_entity }
    end
  end
end
