# frozen_string_literal: true

module Find
  module Courses
    class AccreditingProvidersController < Find::ApplicationController
      def show
        @course = provider.courses.includes(
          :enrichments,
          subjects: [:financial_incentive],
          site_statuses: [:site]
        ).find_by!(course_code: params[:course_code]&.upcase).decorate

        render_not_found if @course.accrediting_provider.blank? || !@course.is_published?
      end
    end
  end
end
