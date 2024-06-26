# frozen_string_literal: true

module Find
  class CoursesController < ApplicationController
    include ApplyRedirect

    before_action -> { render_not_found if provider.nil? }

    before_action :render_feedback_component, only: :show

    def show
      @course = provider.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site]
      ).find_by!(course_code: params[:course_code]&.upcase).decorate

      render_not_found unless @course.is_published?
    end
  end
end
