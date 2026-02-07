# frozen_string_literal: true

module Paginatable
  extend ActiveSupport::Concern

  private

  def calculate_offset
    return params[:offset].to_i if params[:offset].present?

    page = params[:page].to_i
    page = 1 if page < 1

    (page - 1) * per_page
  end

  def per_page(default: 10)
    requested = params[:per_page].to_i
    requested.positive? ? [ requested, 100 ].min : default
  end
end
