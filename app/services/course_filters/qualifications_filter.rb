# frozen_string_literal: true

module CourseFilters
  class QualificationsFilter < BaseFilter
    delegate :course_type, to: :course_search_service

    def call(scope)
      scope.with_qualifications(qualifications)
    end

    def add_filter?
      qualifications.present?
    end

    def qualifications
      return [] if filter[:qualification].blank? || course_type == :undergraduate

      filter[:qualification] = filter[:qualification].values if filter[:qualification].is_a?(Hash)
      filter[:qualification] = filter[:qualification].split(',') if filter[:qualification].is_a?(String)

      if filter[:qualification].include?('pgce pgde')
        filter[:qualification] -= ['pgce pgde']
        filter[:qualification] |= %w[pgce pgde]
      end

      filter[:qualification] |= %w[pgde_with_qts] if filter[:qualification].is_a?(Array) && filter[:qualification].include?('pgce_with_qts')

      filter[:qualification]
    end
  end
end
