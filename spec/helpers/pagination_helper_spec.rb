# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaginationHelper do
  describe "#pagy_series" do
    let(:pagy) { double("Pagy", page: current_page, pages: total_pages) }

    context "when total pages is 7 or less" do
      let(:total_pages) { 5 }
      let(:current_page) { 3 }

      it "returns all pages without ellipsis" do
        expect(helper.pagy_series(pagy)).to eq([ 1, 2, 3, 4, 5 ])
      end
    end

    context "when at the start" do
      let(:total_pages) { 10 }
      let(:current_page) { 2 }

      it "shows first pages with ellipsis at end" do
        expect(helper.pagy_series(pagy)).to eq([ 1, 2, 3, 4, "...", 10 ])
      end
    end

    context "when at the end" do
      let(:total_pages) { 10 }
      let(:current_page) { 9 }

      it "shows last pages with ellipsis at start" do
        expect(helper.pagy_series(pagy)).to eq([ 1, "...", 7, 8, 9, 10 ])
      end
    end

    context "when in the middle" do
      let(:total_pages) { 10 }
      let(:current_page) { 5 }

      it "shows current page with ellipsis on both sides" do
        expect(helper.pagy_series(pagy)).to eq([ 1, "...", 4, 5, 6, "...", 10 ])
      end
    end
  end

  describe "#pagy_prev_page" do
    let(:pagy) { double("Pagy", page: current_page) }

    context "when on first page" do
      let(:current_page) { 1 }

      it "returns nil" do
        expect(helper.pagy_prev_page(pagy)).to be_nil
      end
    end

    context "when on second page" do
      let(:current_page) { 2 }

      it "returns 1" do
        expect(helper.pagy_prev_page(pagy)).to eq(1)
      end
    end

    context "when on page 5" do
      let(:current_page) { 5 }

      it "returns 4" do
        expect(helper.pagy_prev_page(pagy)).to eq(4)
      end
    end
  end

  describe "#pagy_next_page" do
    let(:pagy) { double("Pagy", page: current_page, pages: total_pages) }

    context "when on last page" do
      let(:current_page) { 10 }
      let(:total_pages) { 10 }

      it "returns nil" do
        expect(helper.pagy_next_page(pagy)).to be_nil
      end
    end

    context "when on first page" do
      let(:current_page) { 1 }
      let(:total_pages) { 10 }

      it "returns 2" do
        expect(helper.pagy_next_page(pagy)).to eq(2)
      end
    end

    context "when on page 5" do
      let(:current_page) { 5 }
      let(:total_pages) { 10 }

      it "returns 6" do
        expect(helper.pagy_next_page(pagy)).to eq(6)
      end
    end
  end
end
