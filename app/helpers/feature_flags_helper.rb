# frozen_string_literal: true

module FeatureFlagsHelper
  def feature_flag_tag(feature_name)
    govuk_tag(
      text: feature_flag_text(feature_name).humanize,
      colour: feature_flag_colour(FeatureFlag.active?(feature_name)),
    )
  end

  def feature_flag_last_updated(feature_name)
    last_updated = FeatureFlag.last_updated(feature_name)

    if last_updated
      formatted_date = Time.zone.parse(last_updated).to_fs(:govuk_date_and_time)

      "Changed to #{feature_flag_text(feature_name)} at #{formatted_date}"
    else
      "This flag has not been updated"
    end
  end

private

  def feature_flag_text(feature_name)
    t("feature_flags.active.#{FeatureFlag.active?(feature_name)}")
  end

  def feature_flag_colour(active)
    active ? "green" : "grey"
  end
end
