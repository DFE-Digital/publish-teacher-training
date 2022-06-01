# frozen_string_literal: true

def enable_features(*feature_keys)
  allow(FeatureService).to receive(:enabled?).and_return(false)
  feature_keys.each do |feature_key|
    allow(FeatureService).to receive(:enabled?).with(feature_key).and_return(true)
  end
end

def disable_features(*feature_keys)
  feature_keys.each do |feature_key|
    allow(FeatureService).to receive(:enabled?).with(feature_key).and_return(false)
  end
end

def given_the_can_edit_current_and_next_cycles_feature_flag_is_disabled
  allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
end
