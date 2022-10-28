module Find
  class CoursesController < ApplicationController
    def show
      @course = provider.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site],
      ).find_by!(course_code: params[:course_code]).decorate
    end
  end
end
