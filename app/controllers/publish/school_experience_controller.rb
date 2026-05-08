module Publish
  class SchoolExperienceController < ApplicationController
    def edit
      @course = find_course
    end

    def update
      @course = find_course
      # update logic later
    end

    private

    def find_course
      Course.find_by!(course_code: params[:code])
    end
  end
end
