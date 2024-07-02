# frozen_string_literal: true

module Find
  class PlacementsController < ApplicationController
    before_action -> { render_not_found if provider.nil? }

    def index
      @course = provider.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site]
      ).find_by!(course_code: params[:course_code]&.upcase).decorate

      render_not_found unless @course.is_published?
    end
  end
end
