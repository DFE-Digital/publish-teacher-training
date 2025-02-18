# frozen_string_literal: true

class FindV2ResultsConstraint
  def self.matches?(_request)
    Settings.features.v2_results.present?
  end
end
