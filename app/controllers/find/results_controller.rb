# frozen_string_literal: true

module Find
  class ResultsController < ApplicationController
    after_action :store_result_fullpath_for_backlinks, :send_analytics_event, :record_recent_search, only: [:index]

    def index
      @address = Geolocation::Address.query(location_params)

      @search_courses_form = ::Courses::SearchForm.new(search_form_params)
      @search_params = @search_courses_form.search_params
      @courses_query = ::Courses::Query.new(params: @search_params.dup)
      @courses = @courses_query.call
      @courses_count = @courses_query.count
      @filter_counts = @search_courses_form.filter_counts
      @show_start_date = (params[:start_date] & %w[jan_to_aug september oct_to_jul]).present? || params[:order] == "start_date_ascending"

      @pagy, @results = pagy(@courses, count: @courses_count, page:)
      respond_to do |format|
        format.html do
          render :index
        end
      end
    end

  private

    def send_analytics_event
      Analytics::SearchResultsEvent.new(
        request:,
        total: @courses_count,
        page: @pagy.page,
        search_params: @search_params,
        track_params: params.permit(:utm_source, :utm_medium),
        results: @results,
      ).send_event
    end

    def search_form_params
      search_courses_params.merge(@address.params)
    end

    def search_courses_params
      Find::SearchParams.permit(params)
    end

    def location_params
      location = params[:location]
      location.is_a?(String) ? location : nil
    end

    def store_result_fullpath_for_backlinks
      cookies[:results_path] = { value: request.fullpath, httponly: true }
    end

    def page
      value = params[:page]
      return 1 unless value.is_a?(String) || value.is_a?(Numeric)

      value.to_i.clamp(1..)
    end

    def record_recent_search
      return unless authenticated?
      return unless meaningful_for_recent_search?

      Find::RecentSearchRecorder.call(
        candidate: @candidate,
        search_params: @search_params,
      )
    end

    def meaningful_for_recent_search?
      params.keys.intersect?(%w[subjects
                                location
                                can_sponsor_visa
                                funding
                                study_types
                                qualifications
                                send_courses
                                minimum_degree_required
                                provider_name])
    end
  end
end
