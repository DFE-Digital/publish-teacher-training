# frozen_string_literal: true

module Find
  class CoursesController < ApplicationController
    include ApplyRedirect
    include GetIntoTeachingRedirect
    include ProviderWebsiteRedirect

    before_action -> { render_not_found if provider.nil? }

    before_action :render_feedback_component, only: :show
    before_action :set_course, only: %i[show confirm_apply]

    def show
      distance_from_location if location_params.present?

      @saved_course = @candidate&.saved_courses&.find_by(course_id: @course.id)

      render_not_found unless @course.is_published?

      @apply_action_column_class = apply_action_column_class

      @enrichment = @course.latest_published_enrichment
    end

    def confirm_apply; end

    def location_params
      location = params[:location]
      location.is_a?(String) ? location : nil
    end

    def distance_from_location
      @address = Geolocation::Address.query(location_params)
      return if @address.latitude.nil? || @address.longitude.nil?

      @distance_from_location ||= ::Courses::NearestSchoolQuery.new(
        courses: [@course],
        latitude: @address.latitude,
        longitude: @address.longitude,
      ).call.first.distance_to_search_location.ceil
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
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site],
      ).find_by!(course_code: params[:course_code]&.upcase).decorate
    end
  end
end
