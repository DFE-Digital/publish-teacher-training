# frozen_string_literal: true

module Exports
  module CourseColumns
    # A CSV carries no encoding declaration, so Excel falls back to the legacy
    # Windows code page and renders the UTF-8 "£" (C2 A3) as "Â£". This byte
    # order mark, written first, tells it the file is UTF-8.
    BYTE_ORDER_MARK = "\uFEFF"

    def status(course)
      Publish::Courses::StatusTag.token(course).to_s.humanize
    end

    def age_range(course)
      return if course.age_range_in_years.blank?

      course.decorate.age_range
    end
  end
end
