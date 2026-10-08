# frozen_string_literal: true

module Find
  class SitemapsController < ApplicationController
    skip_before_action :persist_session_cookie

    def show
      # Only the three columns the XML needs. Loading the courses as records
      # (with enrichments, schools and providers) took ~25s and ~1.5GB per
      # request, which is what crawlers fetching this twice a day looked like
      # in the pod memory graphs.
      @courses = RecruitmentCycle.current.courses
                                 .visible_in_find
                                 .joins(:provider)
                                 .pluck("provider.provider_code", "course.course_code", "course.changed_at")

      expires_in(1.day, public: true)
    end
  end
end
