# frozen_string_literal: true

module Find
  class CoursesController < ApplicationController
    include ApplyRedirect
    include GetIntoTeachingRedirect
    include ProviderWebsiteRedirect

    before_action -> { render_not_found if provider.nil? }

    before_action :render_feedback_component, only: :show
    before_action :set_search_params, only: :show
    before_action :set_course, only: %i[show confirm_apply]

    def show
      distance_from_location if params[:location]

      @saved_course = @candidate&.saved_courses&.find_by(course_id: @course.id)

      render_not_found unless @course.is_published?

      @apply_action_column_class = apply_action_column_class
    end

    def confirm_apply; end

    def distance_from_location
      @coordinates = Geolocation::CoordinatesQuery.new(params[:location]).call
      @distance_from_location ||= ::Courses::NearestSchoolQuery.new(
        courses: [@course],
        latitude: @coordinates[:latitude],
        longitude: @coordinates[:longitude],
      ).call.first.distance_to_search_location.ceil
    end

    def legacy_paramater_keys
      %i[
        fulltime
        hasvacancies
        lat
        lng
        parttime
        prev_l
        prev_lat
        prev_lng
        prev_loc
        prev_lq
        prev_query
        prev_rad
        qualifications
        query
        rad
        senCourses
      ]
    end

    def set_search_params
      return if params[:search_params].blank?

      session[:search_params] = ActionController::Parameters.new(
        Rack::Utils.parse_nested_query(params[:search_params]),
      ).permit(
        *legacy_paramater_keys,
        :visa_status,
        :age_group,
        :c,
        :can_sponsor_visa,
        :degree_required,
        :engineers_teach_physics,
        :funding,
        :has_vacancies,
        :university_degree_status,
        :applications_open,
        :l,
        :latitude,
        :loc,
        :long,
        :longitude,
        :lq,
        :radius,
        :send_courses,
        :sortby,
        "provider.provider_name",
        c: [],
        qualification: [],
        qualifications: [], # Legacy
        study_type: [],
        subjects: [],
        subject_codes: [], # Legacy
      )
    end

  private

    def apply_action_column_class
      if FeatureFlag.active?(:candidate_accounts) && CycleTimetable.apply_deadline_passed
        "govuk-grid-column-full"
      elsif FeatureFlag.active?(:candidate_accounts) && !CycleTimetable.apply_deadline_passed
        "govuk-grid-column-one-third-from-desktop"
      else
        "govuk-grid-column-one-half"
      end
    end

    def set_course
      @course = provider.courses.includes(
        :latest_enrichment,
        :latest_published_enrichment,
        :accrediting_provider,
        :study_sites,
        provider: [:recruitment_cycle],
        subjects: [:financial_incentive],
        site_statuses: [:site],
      ).find_by!(course_code: params[:course_code]&.upcase).decorate
    end
  end
end
