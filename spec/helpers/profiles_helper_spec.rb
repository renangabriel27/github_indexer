# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfilesHelper, type: :helper do
  describe "#format_rescan_wait_time" do
    {
      0 => "profiles.time.moments",
      -10 => "profiles.time.moments",
      30 => "profiles.time.one_minute",
      60 => "profiles.time.one_minute"
    }.each do |seconds, i18n_key|
      it "returns #{i18n_key} for #{seconds} seconds" do
        expect(helper.format_rescan_wait_time(seconds)).to eq(I18n.t(i18n_key))
      end
    end

    it "returns minutes message with correct count for > 60 seconds" do
      expect(helper.format_rescan_wait_time(180)).to eq(I18n.t("profiles.time.minutes", count: 3))
      expect(helper.format_rescan_wait_time(121)).to eq(I18n.t("profiles.time.minutes", count: 3)) # ceils
    end

    it "works with different locales" do
      I18n.with_locale(:"pt-BR") do
        expect(helper.format_rescan_wait_time(180)).to eq("3 minutos")
      end
    end
  end
end
