# frozen_string_literal: true

module Publish
  module Schools
    module BulkUpdate
      # Applies one placement school change to many courses.
      #
      # The change is a diff, not a list: each course keeps the schools it
      # already has, gains the ones being added and loses the ones being
      # removed. Two courses with different schools stay different afterwards.
      #
      # Each course is written by the same service a single course goes through,
      # in a transaction of its own. One long transaction over hundreds of
      # courses would hold thousands of row locks for minutes and lose every
      # success to the first failure, so a course that cannot be written is
      # reported and the rest carry on.
      class Apply
        include ServicePattern

        # Which courses were written and which were not. The caller decides what
        # to do about the ones that were not - this only has to be honest about
        # them, which the count it used to return could not be.
        Result = Data.define(:updated_ids, :failed_ids)

        def initialize(courses:, added_uuids:, removed_uuids:)
          @courses = courses
          @added_uuids = Array(added_uuids)
          @removed_uuids = Array(removed_uuids)
        end

        def call
          updated_ids = []
          failed_ids = []

          # Every school written would otherwise stamp its course and the
          # provider. changed_at is unique on both, so a bulk change would put
          # thousands of writes on one provider row; suppress them and stamp the
          # provider once. Each course still gets its own timestamp, from its
          # own save.
          TouchSuppression.suppress do
            courses.includes(schools: :provider_school).find_each do |course|
              (apply_to(course) ? updated_ids : failed_ids) << course.id
            end
          end

          ::ProviderSchools::TouchParents.call(provider:) if updated_ids.any? && provider

          Result.new(updated_ids:, failed_ids:)
        end

      private

        attr_reader :courses, :added_uuids, :removed_uuids

        def apply_to(course)
          UpdateCourseSchoolsService.call(
            course:,
            school_uuids: school_uuids_for(course),
            raise_on_missing_provider_schools: false,
            notify: false,
          )

          true
        rescue StandardError
          # Reported by whoever called this, once, naming every course still
          # outstanding - rather than once per course per attempt.
          false
        end

        def school_uuids_for(course)
          (course.schools.map(&:uuid) + added_uuids - removed_uuids).uniq
        end

        # Every course in a bulk update belongs to the same provider - the
        # scopes are all that provider's courses - so one stamp covers them.
        def provider
          @provider ||= courses.first&.provider
        end
      end
    end
  end
end
