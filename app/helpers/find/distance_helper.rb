# frozen_string_literal: true

module Find
  module DistanceHelper
    def distance_in_miles(miles)
      return I18n.t("find.distance.less_than_one_mile") if miles.to_f < 1

      pluralize(miles.to_f.ceil, "mile")
    end
  end
end
