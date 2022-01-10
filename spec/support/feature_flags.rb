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
