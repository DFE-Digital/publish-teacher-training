# frozen_string_literal: true

class FindV1ResultsConstraint
  def self.matches?(_request)
    !FeatureFlag.active?(:prefiltering_find_redesign)
  end
end
