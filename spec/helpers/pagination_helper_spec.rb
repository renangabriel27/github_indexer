# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaginationHelper do
  describe "#pagy_series" do
    def pagy(page:, pages:)
      double("Pagy", page: page, pages: pages)
    end

    it "returns all pages without ellipsis when total pages is 7 or less" do
      expect(helper.pagy_series(pagy(page: 3, pages: 5))).to eq([ 1, 2, 3, 4, 5 ])
    end

    it "adds ellipsis at appropriate positions for larger page counts" do
      expect(helper.pagy_series(pagy(page: 2, pages: 10))).to eq([ 1, 2, 3, 4, "...", 10 ])
      expect(helper.pagy_series(pagy(page: 9, pages: 10))).to eq([ 1, "...", 7, 8, 9, 10 ])
      expect(helper.pagy_series(pagy(page: 5, pages: 10))).to eq([ 1, "...", 4, 5, 6, "...", 10 ])
    end
  end

  describe "#pagy_prev_page and #pagy_next_page" do
    it "returns nil at boundaries, otherwise adjacent page" do
      pagy = double("Pagy", page: 1, pages: 10)
      expect(helper.pagy_prev_page(pagy)).to be_nil
      expect(helper.pagy_next_page(pagy)).to eq(2)

      pagy = double("Pagy", page: 10, pages: 10)
      expect(helper.pagy_prev_page(pagy)).to eq(9)
      expect(helper.pagy_next_page(pagy)).to be_nil
    end
  end
end
