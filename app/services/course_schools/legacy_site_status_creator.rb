# frozen_string_literal: true

# Attaches a Site to a Course via the legacy SiteStatus model. Thin
# wrapper around Course#add_site! so the old write is isolated in one
# file, deletable as a single step when course reads migrate to the
# new Course::School model.
module CourseSchools
  class LegacySiteStatusCreator
    include ServicePattern

    def initialize(course:, site:)
      @course = course
      @site = site
    end

    def call
      # Course#add_site! is private on purpose (called from Course#sites=);
      # wrap it here so the legacy write is still isolated in this one file.
      @course.send(:add_site!, site: @site)
    end
  end
end
