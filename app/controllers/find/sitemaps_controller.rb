# frozen_string_literal: true

module Find
  class SitemapsController < ApplicationController
    def show
      # Only the three columns the XML needs. Loading the courses as records
      # (with enrichments, schools and providers) took ~25s and ~1.5GB per
      # request, which is what crawlers fetching this twice a day looked like
      # in the pod memory graphs.
      @courses = Course.where(id: RecruitmentCycle.current.courses.findable.select(:id))
                       .joins(:provider)
                       .pluck("provider.provider_code", "course.course_code", "course.changed_at")

      expires_in(1.day, public: true)
    end
  end
end
