module Publish
  module Courses
    module BulkUpdate
      class BulkUpdateSchoolExperienceController < ApplicationController
        def edit
          @course = Course.find_by!(course_code: params[:code])
        end

        def review
          @course = Course.find_by!(course_code: params[:code])
        end
      end
    end
  end
end
