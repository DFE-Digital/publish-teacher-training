# frozen_string_literal: true

class CourseWizard
  module Repositories
    # An edit of a saved course, kept apart from the course drafts so that a
    # draft's URL cannot open an edit's answers
    class CourseEdit < Course
      def self.key_prefix
        "course_edit_wizard"
      end
    end
  end
end
