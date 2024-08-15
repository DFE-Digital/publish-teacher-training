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
          can_sponsor_visa: ActiveModel::Type::Boolean.new.cast(params.dig(:pre_filter, :can_sponsor_visa)),
          **geocode_params_for(params.dig(:pre_filter, :lq))
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

      def geocode_params_for(query)
        return {} if query.blank?

        results = Geocoder.search(query, components: 'country:UK').first
        return {} unless results

        {
          l: 1,
          latitude: results.latitude,
          longitude: results.longitude,
          loc: results.address,
          lq: query,
          c: country(results),
          sortby: ResultsView::DISTANCE,
          radius: ResultsView::MILES
        }
      end

      def country(results)
        flattened_results = results.address_components.map(&:values).flatten
        countries = [*DEVOLVED_NATIONS, 'England'].flatten

        countries.each { |country| return country if flattened_results.include?(country) }
      end
    end
  end
end
