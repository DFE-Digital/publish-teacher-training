module Courses
  class StartDateController < ApplicationController
    include CourseBasicDetailConcern

  private

    def current_step
      :start_date
    end

    def error_keys
      [:start_date]
    end
  end
end
