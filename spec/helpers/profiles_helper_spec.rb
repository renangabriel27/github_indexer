# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfilesHelper, type: :helper do
  describe "#format_rescan_wait_time" do
    context "when seconds is 0 or less" do
      it "returns moments message" do
        expect(helper.format_rescan_wait_time(0)).to eq(I18n.t("profiles.time.moments"))
        expect(helper.format_rescan_wait_time(-10)).to eq(I18n.t("profiles.time.moments"))
      end
    end

    context "when seconds is less than or equal to 60" do
      it "returns one minute message" do
        expect(helper.format_rescan_wait_time(1)).to eq(I18n.t("profiles.time.one_minute"))
        expect(helper.format_rescan_wait_time(30)).to eq(I18n.t("profiles.time.one_minute"))
        expect(helper.format_rescan_wait_time(60)).to eq(I18n.t("profiles.time.one_minute"))
      end
    end

    context "when seconds is greater than 60" do
      it "returns minutes message with correct count" do
        expect(helper.format_rescan_wait_time(61)).to eq(I18n.t("profiles.time.minutes", count: 2))
        expect(helper.format_rescan_wait_time(120)).to eq(I18n.t("profiles.time.minutes", count: 2))
        expect(helper.format_rescan_wait_time(180)).to eq(I18n.t("profiles.time.minutes", count: 3))
        expect(helper.format_rescan_wait_time(300)).to eq(I18n.t("profiles.time.minutes", count: 5))
      end
    end

    context "when seconds rounds up to next minute" do
      it "ceils the minute count" do
        # 121 seconds = 2.01 minutes, should ceil to 3
        expect(helper.format_rescan_wait_time(121)).to eq(I18n.t("profiles.time.minutes", count: 3))
      end
    end

    context "with different locales" do
      it "works in pt-BR" do
        I18n.with_locale(:"pt-BR") do
          expect(helper.format_rescan_wait_time(0)).to eq("alguns instantes")
          expect(helper.format_rescan_wait_time(30)).to eq("1 minuto")
          expect(helper.format_rescan_wait_time(180)).to eq("3 minutos")
        end
      end

      it "works in en" do
        I18n.with_locale(:en) do
          expect(helper.format_rescan_wait_time(0)).to eq("a few moments")
          expect(helper.format_rescan_wait_time(30)).to eq("1 minute")
          expect(helper.format_rescan_wait_time(180)).to eq("3 minutes")
        end
      end
    end
  end
end
