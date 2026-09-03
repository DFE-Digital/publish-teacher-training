# frozen_string_literal: true

module Find
  class PlacementsController < ApplicationController
    include CourseSchoolPreloads

    before_action -> { render_not_found if provider.nil? || provider.selectable_school.blank? }

    def index
      @course = provider.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        **school_preloads,
      ).find_by!(course_code: params[:course_code]&.upcase).decorate

      render_not_found unless @course.is_published?
    end
  end
end
