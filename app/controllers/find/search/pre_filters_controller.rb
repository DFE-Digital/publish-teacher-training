# frozen_string_literal: true

module Find
  module Search
    class PreFiltersController < Find::ApplicationController
      def new; end

      def create
        redirect_to find_results_path(
          has_vacancies: true,
          applications_open: true,
          keywords: params.dig(:pre_filter, :keywords),
          lq: params.dig(:pre_filter, :lq),
          can_sponsor_visa: ActiveModel::Type::Boolean.new.cast(params.dig(:pre_filter, :can_sponsor_visa)),
        )
      end

      helper_method :primary_courses_path, :secondary_courses_path, :further_education_courses_path

      private

      def primary_courses_path
        find_results_path(has_vacancies: true, applications_open: true, subjects: Subject.where(type: 'PrimarySubject').pluck(:subject_code))
      end

      def secondary_courses_path
        find_results_path(has_vacancies: true, applications_open: true, subjects: Subject.where(type: 'SecondarySubject').pluck(:subject_code))
      end

      def further_education_courses_path
        find_results_path(has_vacancies: true, applications_open: true, subjects: Subject.where(type: 'FurtherEducationSubject').pluck(:subject_code))
      end
    end
  end
end
