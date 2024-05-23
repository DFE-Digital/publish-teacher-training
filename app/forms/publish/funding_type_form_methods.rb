# frozen_string_literal: true

module Publish
  module FundingTypeFormMethods
    private

    def compute_fields
      course_enrichment
        .attributes
        .symbolize_keys
        .slice(*declared_fields)
        .merge(new_attributes)
        .symbolize_keys
    end

    def course
      course_enrichment.course
    end
  end
end
