# frozen_string_literal: true

class Course
  # A placement school change that has been chosen but not yet applied.
  #
  # The attach page no longer writes: it records what the provider ticked and
  # hands the draft on to the bulk update pages, which apply it once the
  # provider has said which courses it is for. The URL carries the uuid.
  #
  # The baseline travels with the selection rather than being read back from
  # the course. The pages play back a diff and the apply writes that same diff,
  # so both have to be measured against the schools that were attached when
  # the provider was looking at them - not against whatever the course holds
  # by the time they press the button.
  #
  # A row, rather than a cache entry, so it is there whatever the cache is
  # doing - development runs with none - and so support can see one.
  class SchoolBulkUpdateDraft < ApplicationRecord
    self.table_name = "course_school_bulk_update_draft"

    EXPIRES_IN = 24.hours

    belongs_to :course
    # Who started it. Kept for the record; any user of the provider may act on
    # the provider's courses, so it is not what resolves a draft.
    belongs_to :user

    scope :unexpired, -> { where(expires_at: Time.current..) }
    scope :expired, -> { where(expires_at: ...Time.current) }

    def self.start(course:, user:, school_uuids:, baseline_uuids:)
      create!(
        course:,
        user:,
        school_uuids: Array(school_uuids),
        baseline_uuids: Array(baseline_uuids),
        expires_at: EXPIRES_IN.from_now,
      )
    end

    # Whatever the URL holds. Anything that is not a live draft for this course
    # - blank, malformed, somebody else's, spent, or past its time - is nil.
    def self.resolve(course:, state_key:)
      return if state_key.blank?

      unexpired.find_by(course:, uuid: state_key)
    end

    def state_key
      uuid
    end

    def added_uuids
      school_uuids - baseline_uuids
    end

    def removed_uuids
      baseline_uuids - school_uuids
    end

    def changed?
      added_uuids.any? || removed_uuids.any?
    end
  end
end
