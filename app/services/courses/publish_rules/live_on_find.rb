# frozen_string_literal: true

# Single source of truth for "does this course have a live page on Find?", which
# decides whether Publish offers a link to it or only a preview.
#
# Content status is a required argument rather than something read off the
# course, because the two callers get it from different places: the course page
# from Course#content_status, and the course list from the content_status column
# Publish::Courses::Query computes in SQL. Reading it off the course in a list
# would run the enrichment service once per row.
#
# Find serves the current cycle only (Find::ApplicationController#provider scopes
# to RecruitmentCycle.current), and Publish holds the current and next cycle, so
# "not next cycle" is the cycle test.
#
# The year comes off the course's already-loaded cycle and is compared against
# the timetable rather than through Course#next_recruitment_cycle?, which looks
# the current cycle up from the database on every call — once per row on a
# course list.
module Courses
  module PublishRules
    class LiveOnFind
      def self.applies?(course, content_status:)
        content_status.to_s == "published" &&
          course.recruitment_cycle_year.to_i <= Find::CycleTimetable.current_year &&
          (course.is_running? || course.without_employing_school?)
      end
    end
  end
end
