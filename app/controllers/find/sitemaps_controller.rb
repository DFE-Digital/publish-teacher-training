# frozen_string_literal: true

module Find
  class SitemapsController < ApplicationController
    def show
      @courses = ::V3::CourseSearchService.call(filter: nil, sort: nil, course_scope: RecruitmentCycle.current.courses.findable)

      expires_in(1.day, public: true)
    end
  end
end
