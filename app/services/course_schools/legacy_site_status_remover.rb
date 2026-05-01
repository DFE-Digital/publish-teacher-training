# frozen_string_literal: true

# Detaches a Site from a Course via the legacy SiteStatus model. Thin
# wrapper around Course#remove_site! — destroy for new courses, suspend
# for live ones, matching existing behaviour.
module CourseSchools
  class LegacySiteStatusRemover
    include ServicePattern

    def initialize(course:, site:)
      @course = course
      @site = site
    end

    def call
      # Course#remove_site! is private on purpose (called from Course#sites=);
      # wrap it here so the legacy write is still isolated in this one file.
      @course.send(:remove_site!, site: @site)
    end
  end
end
