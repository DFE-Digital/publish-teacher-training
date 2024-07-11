# frozen_string_literal: true

module Find
  module Courses
    class TrainingWithDisabilitiesController < Find::ApplicationController
      before_action -> { render_not_found if provider.nil? }
      before_action -> { render_not_found if provider.train_with_disability.blank? }

      def show
        @course = provider.courses.includes(
          :enrichments,
          subjects: [:financial_incentive],
          site_statuses: [:site]
        ).find_by!(course_code: params[:course_code]&.upcase).decorate
      end
    end
  end
end
