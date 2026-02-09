# frozen_string_literal: true

module ProfilesHelper
  def format_rescan_wait_time(seconds)
    return I18n.t("profiles.time.moments") if seconds <= 0

    minutes = (seconds / 60.0).ceil

    if minutes <= 1
      I18n.t("profiles.time.one_minute")
    else
      I18n.t("profiles.time.minutes", count: minutes)
    end
  end
end
