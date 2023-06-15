# frozen_string_literal: true

module Sites
  class CopyToCourseService
    include ServicePattern

    def initialize(new_site:, new_course:)
      @new_site = new_site
      @new_course = new_course
    end

    def call
      return copy_study_site if new_site.study_site?

      copy_school
    end

    private

    attr_reader :new_site, :new_course

    def copy_school
      new_course.site_statuses.create(
        site: new_site,
        status: :new_status
      )
    end

    def copy_study_site
      new_course.study_site_placements.create(site: new_site)
    end
  end
end
