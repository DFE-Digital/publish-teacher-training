# frozen_string_literal: true

module Find
  class CoursesController < ApplicationController
    include ApplyRedirect
    include GetIntoTeachingRedirect
    include ProviderWebsiteRedirect

    before_action -> { render_not_found if provider.nil? }

    before_action :render_feedback_component, only: :show

    def show
      @course = provider.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site]
      ).find_by!(course_code: params[:course_code]&.upcase).decorate

      matched_params = MatchOldParams.call(request.query_parameters)
                                     .merge(
                                       keywords: request.query_parameters[:keywords],
                                       **geocode_params_for(request.query_parameters[:lq])
                                     )

      @filters_view = ResultFilters::FiltersView.new(params: matched_params)

      render_not_found unless @course.is_published?
    end

    private

    def geocode_params_for(query)
      return {} if query.blank?

      results = Geocoder.search(query, components: 'country:UK').first
      return {} unless results

      {
        l: '1',
        latitude: results.latitude,
        longitude: results.longitude,
        loc: results.address,
        lq: query,
        c: country(results),
        sortby: ResultsView::DISTANCE,
        radius: request.query_parameters.fetch(:radius, ResultsView::MILES)
      }
    end

    def country(results)
      flattened_results = results.address_components.map(&:values).flatten
      countries = [*DEVOLVED_NATIONS, 'England'].flatten

      countries.each { |country| return country if flattened_results.include?(country) }
    end
  end
end
