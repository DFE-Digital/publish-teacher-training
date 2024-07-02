# frozen_string_literal: true

module Find
  class CoursesController < ApplicationController
    include ApplyRedirect

    before_action -> { render_not_found if provider.nil? }
    before_action :set_course, only: %i[show placements]

    before_action :render_feedback_component, only: :show

    def show
      render_not_found unless @course.is_published?
    end

    def placements
      render_not_found unless @course.is_published?
    end

    private

    def set_course
      @course = provider.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site]
      ).find_by!(course_code: params[:course_code]&.upcase).decorate
    end
  end
end
