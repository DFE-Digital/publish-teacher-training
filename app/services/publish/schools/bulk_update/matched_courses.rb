# frozen_string_literal: true

module Publish
  module Schools
    module BulkUpdate
      # The courses a bulk update scope matched, split into the ones that will
      # be updated and the ones that will not.
      #
      # A course cannot be left with no schools, so a change that removes every
      # school it has passes it by. Since a course keeps whatever it is not
      # losing and gains whatever is being added, that can only happen when the
      # change adds nothing - which is why the question is only asked then.
      #
      # Three queries whatever the size of the provider: which courses matched,
      # which of them cannot be updated, and the list rows for the table.
      class MatchedCourses
        def initialize(scope:, added_uuids:, removed_uuids:)
          @scope = scope
          @added_uuids = Array(added_uuids)
          @removed_uuids = Array(removed_uuids)
        end

        def updatable
          @updatable ||= rows.reject { |course| excluded_ids.include?(course.id) }
        end

        def excluded
          @excluded ||= rows.select { |course| excluded_ids.include?(course.id) }
        end

        def count
          ids.size
        end

        # What the write needs, and all it needs. The confirm action renders
        # nothing, so it never asks for the rows - which is the whole of the
        # list query, enrichment aggregate and all, for a list of integers.
        def ids
          @ids ||= matched_ids - excluded_ids.to_a
        end

      private

        attr_reader :scope, :added_uuids, :removed_uuids

        # Decorated on the way out, as Publish::CourseList sends its own rows:
        # the table reads what the decorator adds, an age range under a
        # primary course among them.
        def rows
          @rows ||= Publish::Courses::Query.call(provider:, params: { ids: matched_ids }).map(&:decorate)
        end

        def matched_ids
          @matched_ids ||= scope.relation.pluck(:id)
        end

        def excluded_ids
          @excluded_ids ||= Set.new(excluded_course_ids)
        end

        def excluded_course_ids
          return [] if added_uuids.any? || removed_uuids.empty?

          provider.courses
            .where(id: matched_ids)
            .merge(::Courses::PublishRules::SchoolPresenceExemption.not_exempt)
            # A course with no schools to begin with is not losing its last one,
            # so the explanation would not be true of it.
            .where(id: course_schools.select(:course_id))
            .where.not(id: keeping_a_school)
            .pluck(:id)
        end

        def keeping_a_school
          course_schools
            .joins(:provider_school)
            .where.not(provider_school: { uuid: removed_uuids })
            .select(:course_id)
        end

        # Bounded to the courses this update matched, and that bound is doing
        # real work rather than tidying up. Both subqueries are correct without
        # it, but Postgres answers an unbounded IN over course_school by
        # materialising the whole table and rescanning it once per matched
        # course: seconds for a provider with a few hundred courses, on a page
        # they are only reading.
        def course_schools
          ::Course::School.where(course_id: matched_ids)
        end

        def provider
          scope.course.provider
        end
      end
    end
  end
end
