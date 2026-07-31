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
      # Content statuses that are their own token. Anything else is published in
      # some form, and its token depends on the cycle and application status.
      SELF_EVIDENT_TOKENS = %w[draft rolled_over withdrawn].freeze

      def self.token(course)
        content_status = course.read_attribute(:content_status).to_s
        return content_status.to_sym if SELF_EVIDENT_TOKENS.include?(content_status)

        published_token(course)
      end

      # published / published_with_unpublished_changes
      def self.published_token(course)
        return :scheduled unless Find::CycleTimetable.current_or_previous_year?(course.recruitment_cycle.year)

        course.application_status_open? ? :open : :closed
      end
    end
  end
end
