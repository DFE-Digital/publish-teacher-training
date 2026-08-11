# frozen_string_literal: true

module ProviderSchools
  # Stamps what a single provider school write stamps through TouchProvider and
  # TouchNoSchoolCourses. Bulk writers wrap their loop in
  # TouchSuppression.suppress — so those callbacks don't repeat the work once
  # per school and call this once at the end instead.
  class TouchParents
    def self.call(provider:)
      provider.update_changed_at
      Provider::School.touch_no_school_courses_for(provider)
    end
  end
end
