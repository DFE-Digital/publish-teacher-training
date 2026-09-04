# frozen_string_literal: true

module Publish
  module Schools
    module BulkUpdate
      # Which courses a placement school change is being applied to.
      #
      # One object per radio on the bulk update options page, and the only place
      # that knows what a scope is called and which courses it stands for. The
      # form, the page and the apply all read it, so the answer cannot drift
      # between what the provider was offered, what they were shown, and what
      # was written.
      class Scope
        TOKENS = %w[only_this_course funding secondary subject all].freeze

        class << self
          # In the order the page lists them: this course, then - after the "or"
          # divider - the ways of saying more than one.
          def available(course)
            TOKENS.filter_map do |token|
              scope = new(course:, token:)
              scope if scope.offered?
            end
          end

          def find(course:, token:)
            available(course).find { |scope| scope.token == token }
          end
        end

        attr_reader :course, :token

        def initialize(course:, token:)
          @course = course
          @token = token
        end

        # A course only offers the phase when it has one worth naming, and only
        # offers its subject when there is a subject to name it after.
        def offered?
          case token
          when "secondary" then course.secondary_course?
          when "subject" then subject_name.present?
          else true
          end
        end

        def label
          case token
          when "only_this_course" then t(:only_this_course, course: course.name_and_code)
          when "funding" then t("funding.#{course.funding}")
          when "subject" then t(:subject, subject: subject_name)
          else t(token)
          end
        end

        def relation
          case token
          when "only_this_course" then provider_courses.where(id: course.id)
          when "funding" then provider_courses.where(funding: course.funding)
          when "secondary" then provider_courses.secondary_course
          when "subject" then subject_relation
          else provider_courses
          end
        end

      private

        # Provider is per recruitment cycle and the association is already
        # scoped to kept courses, so "this provider's courses, this cycle, not
        # deleted" needs nothing added to it.
        def provider_courses
          course.provider.courses
        end

        # Primary and further education courses are named after their level
        # rather than a subject - "All primary courses" - so that is what they
        # match on too. A secondary course matches its master subject by id: the
        # subject code is not unique across subject types, and joining subjects
        # would return a course once per subject it shares.
        def subject_relation
          return provider_courses.where(level: course.level) unless course.secondary_course?

          provider_courses.where(
            id: CourseSubject.where(subject_id: course.master_subject_id).select(:course_id),
          )
        end

        def subject_name
          @subject_name ||= if course.secondary_course?
                              master_subject&.name&.downcase
                            else
                              ::Course.levels[course.level].downcase
                            end
        end

        def master_subject
          Subject.find_by(id: course.master_subject_id)
        end

        def t(key, **)
          I18n.t("publish.courses.schools.bulk_update.scopes.#{key}", **)
        end
      end
    end
  end
end
