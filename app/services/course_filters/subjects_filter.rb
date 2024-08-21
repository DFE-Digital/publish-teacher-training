# frozen_string_literal: true

module CourseFilters
  class SubjectsFilter < BaseFilter
    def call(scope)
      scope.with_subjects(subject_codes)
    end

    def add_filter?
      subject_codes.present?
    end

    def subject_codes
      return [] if filter[:subjects].blank?
      return filter[:subjects] if filter[:subjects].is_a? Array
      return filter[:subjects].values if filter[:subjects].is_a?(Hash)

      filter[:subjects].split(',')
    end
  end
end
