# frozen_string_literal: true

module Find
  class SitemapsController < ApplicationController
    def show
      service = FeatureFlag.active?(:course_publishing_uses_new_school_model) ? ::CourseSearchServiceSchools : ::CourseSearchService
      @courses = service.call(filter: nil, sort: nil, course_scope: RecruitmentCycle.current.courses.findable)

      expires_in(1.day, public: true)
    end
  end
end
