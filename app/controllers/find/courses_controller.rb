# frozen_string_literal: true

module Find
  class CoursesController < ApplicationController
    include ApplyRedirect
    include GetIntoTeachingRedirect
    include ProviderWebsiteRedirect

    before_action -> { render_not_found if provider.nil? }

    before_action :render_feedback_component, only: :show
    before_action :set_search_params, only: :show

    def show
      @course = provider.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site]
      ).find_by!(course_code: params[:course_code]&.upcase).decorate

      distance_from_location if params[:location]

      render_not_found unless @course.is_published?
    end

    def distance_from_location
      @coordinates = Geolocation::CoordinatesQuery.new(params[:location]).call
      @distance_from_location ||= ::Courses::NearestSchoolQuery.new(
        courses: [@course],
        latitude: @coordinates[:latitude],
        longitude: @coordinates[:longitude]
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
        Rack::Utils.parse_nested_query(params[:search_params])
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
        'provider.provider_name',
        c: [],
        qualification: [],
        qualifications: [], # Legacy
        study_type: [],
        subjects: [],
        subject_codes: [] # Legacy
      )
    end
  end
end
