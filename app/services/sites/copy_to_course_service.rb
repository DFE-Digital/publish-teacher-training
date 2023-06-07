# frozen_string_literal: true

module Sites
  class CopyToCourseService
    def execute(new_site:, new_course:)
      new_course.site_statuses.create(
        site: new_site,
        status: :new_status
      )
    end
  end
end
