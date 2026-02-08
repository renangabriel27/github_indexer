module ApplicationHelper
  def pagy_series(pagy)
    current_page = pagy.page
    total_pages = pagy.pages
    series = []

    if total_pages <= 7
      (1..total_pages).each { |p| series << p }
    else
      if current_page <= 3
        (1..4).each { |p| series << p }
        series << "..."
        series << total_pages
      elsif current_page >= total_pages - 2
        series << 1
        series << "..."
        ((total_pages - 3)..total_pages).each { |p| series << p }
      else
        series << 1
        series << "..."
        ((current_page - 1)..(current_page + 1)).each { |p| series << p }
        series << "..."
        series << total_pages
      end
    end

    series
  end

  def pagy_prev_page(pagy)
    pagy.page > 1 ? pagy.page - 1 : nil
  end

  def pagy_next_page(pagy)
    pagy.page < pagy.pages ? pagy.page + 1 : nil
  end
end
