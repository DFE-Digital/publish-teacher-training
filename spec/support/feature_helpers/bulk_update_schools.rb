# frozen_string_literal: true

module FeatureHelpers
  # The placement schools page no longer saves on submit: it asks which courses
  # the change is for. A spec that only cares about the course in front of it
  # answers "only this course" and carries on.
  module BulkUpdateSchools
    def and_i_apply_the_change_to_this_course_only
      choose(option: "only_this_course")
      click_button "Continue to view the courses that will be updated"
    end
  end
end
