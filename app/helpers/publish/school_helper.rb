# frozen_string_literal: true

module Publish
  module SchoolHelper
    def school_urn_and_location(school)
      [school.town, school.postcode].select(&:present?).join(', ')
    end
  end
end
