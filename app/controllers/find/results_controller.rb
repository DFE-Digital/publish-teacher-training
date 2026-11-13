# frozen_string_literal: true

module Find
  class ResultsController < ApplicationController
    before_action :require_results_authentication, only: :index, if: :results_authentication_required?
    after_action :store_result_fullpath_for_backlinks, :send_analytics_event, :record_recent_search, only: [:index]

    helper_method :show_email_alert_link?

    def index
      @address = Geolocation::Address.query(location_params)

      @search_courses_form = ::Courses::SearchForm.new(search_form_params)
      @search_params = @search_courses_form.search_params
      @courses_query = ::Courses::Query.new(params: @search_params.dup)
      @courses = @courses_query.call
      @courses_count = @courses_query.count
      @accredited_provider_conflicts = @courses_query.provider_subjects_with_multiple_accredited_providers
      @accredited_provider_names = @courses_query.accredited_provider_names
      @filter_counts = @search_courses_form.filter_counts

      @pagy, @results, @cards = paginate_results

      respond_to do |format|
        format.html do
          render :index
        end
      end
    end

    def sign_in
      if authenticated? || !results_authentication_required?
        return redirect_to(return_to_after_authenticating || find_results_path)
      end

      @sign_in_url = Authentications::CandidateOmniAuth.sign_in_path
    end

  private

    def results_authentication_required?
      FeatureFlag.active?(:require_authentication_for_find_results)
    end

    def require_results_authentication
      return if authenticated?

      store_return_to_after_authenticating

      respond_to do |format|
        format.html { redirect_to find_results_sign_in_path }
        format.json { render json: { redirect: find_results_sign_in_path }, status: :unauthorized }
      end
    end

    # With grouped results, a page holds 10 cards rather than 10 courses, and a
    # card lists a provider's courses of a subject. Without, each course is its
    # own card. @courses_count still counts courses for the heading.
    def paginate_results
      unless FeatureFlag.active?(:group_search_results)
        pagy, results = pagy(@courses, count: @courses_count, page:)
        return [pagy, results, results.map { |course| [course] }]
      end

      result_cards = ::Courses::ResultCards.new(query: @courses_query, page:, per_page: Pagy::DEFAULT[:limit])

      [Pagy.new(count: result_cards.count, page:), result_cards.courses, result_cards.cards]
    end

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

    def show_email_alert_link?
      return unless current_user.present? && FeatureFlag.active?(:email_alerts)

      filters_applied? && meaningful_for_recent_search? && !location_outside_england?
    end

    def location_outside_england?
      @address.country.present? && @address.country != "England"
    end

    def filters_applied?
      @search_courses_form.active_filters.present?
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
