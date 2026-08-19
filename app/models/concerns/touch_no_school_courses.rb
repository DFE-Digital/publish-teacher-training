# frozen_string_literal: true

# A course that is allowed to publish without schools is served by the API with
# all of its provider's schools as locations, so writing a provider school
# changes that course's payload. Bumping `changed_at` is what tells API
# consumers to re-fetch it.
#
# Shaped like TouchProvider: the write itself is the trigger, so every writer
# gets this for free. Bulk writers that would otherwise repeat the sweep once
# per row wrap their loop in TouchSuppression.suppress and call
# `.touch_no_school_courses_for(provider)` once at the end instead.
#
# after_commit rather than after_save/after_destroy: ProviderSchools::Removal
# destroys inside `with_lock`, and sweeping there would hold that row lock for
# the length of the sweep and take course row locks under it — the opposite
# order to attaching a school, which takes the provider school's key-share lock
# first and then touches the course. Running after the transaction commits
# keeps the two paths from deadlocking, and only touches once the write is
# durable.
module TouchNoSchoolCourses
  extend ActiveSupport::Concern

  # The columns a fallback location is serialized from: `code` reads
  # `site_code`, and everything else is read through `gias_school`. An update
  # that leaves both alone cannot change what the API serves, and
  # `after_commit on: :update` fires even for a save that issued no UPDATE at
  # all, so gate the update case on them. Create and destroy always change the
  # set of schools served.
  PAYLOAD_COLUMNS = %w[gias_school_id site_code].freeze

  # Two callbacks, two method names: ActiveSupport dedupes callbacks by filter,
  # so registering the same symbol twice replaces the first registration rather
  # than adding to it.
  included do
    after_commit :touch_no_school_courses, on: %i[create destroy]
    after_commit :touch_no_school_courses_on_update, on: :update
  end

  class_methods do
    def touch_no_school_courses_for(provider)
      # `changed_at` is UNIQUE, so every row needs its own timestamp.
      # update_columns skips the per-course provider touch — TouchProvider has
      # already bumped the provider once.
      Courses::PublishRules::SchoolPresenceExemption
        .falling_back_to_provider_schools(provider)
        .find_each { |course| course.update_columns(changed_at: Time.zone.now) }
    end
  end

private

  def touch_no_school_courses
    return if TouchSuppression.suppressed?

    self.class.touch_no_school_courses_for(provider)
  end

  def touch_no_school_courses_on_update
    return unless saved_changes.keys.intersect?(PAYLOAD_COLUMNS)

    touch_no_school_courses
  end
end
