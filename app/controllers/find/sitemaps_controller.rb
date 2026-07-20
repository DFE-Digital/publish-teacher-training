# frozen_string_literal: true

module Find
  class SitemapsController < ApplicationController
    def show
      service = schools_remodelled ? ::CourseSearchServiceSchools : ::CourseSearchService
      @courses = service.call(filter: nil, sort: nil, course_scope: RecruitmentCycle.current.courses.findable)

      expires_in(1.day, public: true)
    end

    def schools_remodelled
      FeatureFlag.active?(:course_publishing_uses_new_school_model) && Find::CycleTimetable.current_year > 2026
    end
  end
end
