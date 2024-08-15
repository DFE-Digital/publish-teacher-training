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
          **geocode_params_for(params.dig(:pre_filter, :lq))
        )
      end

      private

      def geocode_params_for(query)
        results = Geocoder.search(query, components: 'country:UK').first
        return unless results

        {
          l: 1,
          lq: query,
          latitude: results.latitude,
          longitude: results.longitude,
          loc: results.address,
          lq: query,
          c: country(results),
          sortby: ResultsView::DISTANCE,
          radius: ResultsView::MILES,
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
