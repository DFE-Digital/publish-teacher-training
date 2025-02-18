# frozen_string_literal: true

class FindV1ResultsConstraint
  def self.matches?(_request)
    Settings.features.v2_results.blank?
  end
end
