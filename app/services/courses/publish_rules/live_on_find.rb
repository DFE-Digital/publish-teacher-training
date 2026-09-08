# frozen_string_literal: true

# Single source of truth for "does this course have a live page on Find?", which
# decides whether Publish links to it or only offers a preview.
#
# It mirrors the two guards Find itself applies to a course page:
# Find::CoursesController#show renders the course whenever it is published, and
# Find::ApplicationController#provider looks the provider up under
# RecruitmentCycle.current. Nothing about site statuses comes into it — Find
# serves a published course whose sites are not on UCAS just the same — so
# Publish must not be stricter, or it withholds a link to a page that is there.
#
# The cycle test has to be equality, not "not the next one". Find resolves a
# course by code within the current cycle, so a link built from an earlier
# cycle's row lands on whichever course holds that code today: a different
# course, with nothing to signal the switch.
#
# Content status is a required argument rather than something read off the
# course, because the two callers get it from different places: the course page
# from Course#content_status, and the course list from the content_status column
# Publish::Courses::Query computes in SQL. Reading it off the course in a list
# would run the enrichment service once per row.
module Courses
  module PublishRules
    class LiveOnFind
      def self.applies?(course, content_status:)
        content_status.to_s == "published" &&
          course.recruitment_cycle_year.to_i == Find::CycleTimetable.current_year
      end
    end
  end
end
