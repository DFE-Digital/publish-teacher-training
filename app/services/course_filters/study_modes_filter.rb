# frozen_string_literal: true

module CourseFilters
  class StudyModesFilter < BaseFilter
    def call(scope)
      scope.with_study_modes(study_types)
    end

    def add_filter?
      study_types.present?
    end

    def study_types
      # this passes for strings and arrays
      return [] if filter[:study_type].blank?
      return filter[:study_type] if filter[:study_type].is_a? Array

      filter[:study_type] = filter[:study_type].values if filter[:study_type].is_a?(Hash)

      filter[:study_type].split(',')
    end
  end
end
