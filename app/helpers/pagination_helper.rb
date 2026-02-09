# frozen_string_literal: true

module PaginationHelper
  ELLIPSIS = "..."
  MAX_PAGES_WITHOUT_ELLIPSIS = 7
  PAGES_AT_START = 3
  PAGES_AT_END = 2

  # Generates a series of page numbers with ellipsis for pagination
  # Returns an array like [1, 2, 3, "...", 10] for smart truncation
  def pagy_series(pagy)
    current_page = pagy.page
    total_pages = pagy.pages

    return (1..total_pages).to_a if total_pages <= MAX_PAGES_WITHOUT_ELLIPSIS

    if at_start?(current_page)
      build_start_series(total_pages)
    elsif at_end?(current_page, total_pages)
      build_end_series(total_pages)
    else
      build_middle_series(current_page, total_pages)
    end
  end

  def pagy_prev_page(pagy)
    pagy.page > 1 ? pagy.page - 1 : nil
  end

  def pagy_next_page(pagy)
    pagy.page < pagy.pages ? pagy.page + 1 : nil
  end

  private

  def at_start?(current_page)
    current_page <= PAGES_AT_START
  end

  def at_end?(current_page, total_pages)
    current_page >= total_pages - PAGES_AT_END
  end

  def build_start_series(total_pages)
    [ *1..4, ELLIPSIS, total_pages ]
  end

  def build_end_series(total_pages)
    [ 1, ELLIPSIS, *(total_pages - 3..total_pages) ]
  end

  def build_middle_series(current_page, total_pages)
    [ 1, ELLIPSIS, *(current_page - 1..current_page + 1), ELLIPSIS, total_pages ]
  end
end
