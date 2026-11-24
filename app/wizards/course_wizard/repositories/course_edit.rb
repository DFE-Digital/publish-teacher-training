# frozen_string_literal: true

class CourseWizard
  module Repositories
    # An edit of a saved course, kept apart from the course drafts so that a
    # draft's URL cannot open an edit's answers. The course code and the unit
    # are part of the key, so changing either in an edit URL opens no answers:
    # not another course's, and not a funding type edit's from a visa URL,
    # which skips the funding type check.
    class CourseEdit < Course
      def initialize(course_code:, unit:, state_key:, **)
        super(state_key: "#{course_code}_#{unit}_#{state_key}", **)
      end

      def self.key_prefix
        "course_edit_wizard"
      end
    end
  end
end
