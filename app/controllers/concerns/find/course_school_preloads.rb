# frozen_string_literal: true

module Find
  # Which school association a course page should eager-load, while the
  # :course_publishing_uses_new_school_model flag decides whether schools are read
  # from course_school -> gias_school or from the legacy course_site -> site.
  #
  # Study sites are not covered here: study_site_placements -> site has no
  # canonical model, so anything rendering them keeps its own legacy preload.
  module CourseSchoolPreloads
    extend ActiveSupport::Concern

  private

    def school_preloads
      if FeatureFlag.active?(:course_publishing_uses_new_school_model)
        { schools: %i[gias_school provider_school] }
      else
        { site_statuses: [:site] }
      end
    end
  end
end
