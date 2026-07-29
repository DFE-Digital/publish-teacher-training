# frozen_string_literal: true

module Publish
  module Courses
    # The single status a course displays as, as a token
    # (:open / :closed / :draft / :rolled_over / :scheduled / :withdrawn).
    #
    # This is the value the status filter selects on and the status tag renders,
    # so it is the right key for deciding whether the Status filter varies across
    # a provider's courses. Mirrors StatusTagComponent's tag choice and inverts
    # Query#status_predicate; a drift-guard spec ties the three together.
    #
    # "Open" and "Open *" (unpublished changes) share the token :open — the token
    # is the filterable status, not the rendered label.
    module StatusTag
      def self.token(course)
        case course.read_attribute(:content_status).to_s
        when "draft" then :draft
        when "rolled_over" then :rolled_over
        when "withdrawn" then :withdrawn
        else # published / published_with_unpublished_changes
          if Find::CycleTimetable.current_or_previous_year?(course.recruitment_cycle.year)
            course.application_status_open? ? :open : :closed
          else
            :scheduled
          end
        end
      end
    end
  end
end
