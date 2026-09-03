# frozen_string_literal: true

module Find
  class CoursesController < ApplicationController
    include ApplyRedirect
    include GetIntoTeachingRedirect
    include ProviderWebsiteRedirect

    helper_method :show_interview_process?, :from_previous_cycle?

    before_action -> { render_not_found if provider.nil? }

    before_action :render_feedback_component, only: :show
    before_action :set_course, only: %i[show confirm_apply school_experience_interstitial]

    def show
      distance_from_location if location_params.present?

      @saved_course = @candidate&.saved_courses&.find_by(course_id: @course.id)

      render_not_found and return unless course_available_on_find?

      @apply_action_column_class = apply_action_column_class

      @enrichment = @course.latest_published_enrichment
    end

    def confirm_apply; end

    def school_experience_interstitial
      redirect_to find_confirm_apply_path(provider_code: @course.provider_code, course_code: @course.course_code) unless @course.show_school_experience?
    end

    def location_params
      location = params[:location]
      location.is_a?(String) ? location : nil
    end

    def distance_from_location
      @address = Geolocation::Address.query(location_params)
      return unless @address.coordinates?

      @distance_from_location ||= ::Courses::NearestSchoolQuery.new(
        courses: [@course],
        latitude: @address.latitude,
        longitude: @address.longitude,
      ).call.first.distance_to_search_location.ceil
    end

  private

    def provider
      @provider ||= recruitment_cycle&.providers&.find_by(provider_code: params[:provider_code]&.upcase)
    end

    def recruitment_cycle
      @recruitment_cycle ||= if params[:cycle_year].present?
                               RecruitmentCycle.find_by(year: params[:cycle_year])
                             else
                               RecruitmentCycle.current
                             end
    end

    def from_previous_cycle?
      params[:cycle_year].present?
    end

    def course_available_on_find?
      if from_previous_cycle?
        PreviousCycleCourse.visible?(@course)
      else
        @course.is_published?
      end
    end

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

    def show_interview_process?
      return false if @enrichment.blank?

      @enrichment.interview_process.present? ||
        @enrichment.interview_location.in?(%w[online both])
    end
  end
end
