# frozen_string_literal: true

module Publish
  module Courses
    # Renders a course's status tag from the read-model columns produced by
    # Publish::Courses::Query (content_status + has_unpublished_changes), the
    # course's application_status, and the recruitment-cycle branch — so the list
    # needs no enrichment or site rows.
    #
    # The text/colour mapping mirrors ApplicationDecorator#status_tags*; a
    # cross-check spec asserts this component renders identically to
    # ApplicationDecorator#status_tag.
    class StatusTagComponent < ApplicationComponent
      OPEN_APPLICATION_STATUS_TAGS = {
        published: { text: "Open", colour: "teal" },
        withdrawn: { text: "Withdrawn", colour: "red" },
        empty: { text: "Draft", colour: "grey" },
        draft: { text: "Draft", colour: "grey" },
        published_with_unpublished_changes: { text: "Open *", colour: "teal" },
        rolled_over: { text: "Rolled over", colour: "yellow" },
      }.freeze

      CLOSED_APPLICATION_STATUS_TAGS = OPEN_APPLICATION_STATUS_TAGS.merge(
        published: { text: "Closed", colour: "purple" },
        published_with_unpublished_changes: { text: "Closed *", colour: "purple" },
      ).freeze

      SCHEDULED_STATUS_TAGS = OPEN_APPLICATION_STATUS_TAGS.merge(
        published: { text: "Scheduled", colour: "blue" },
        published_with_unpublished_changes: { text: "Scheduled *", colour: "blue" },
      ).freeze

      def initialize(course:, recruitment_cycle_year:, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @course = course
        @recruitment_cycle_year = recruitment_cycle_year
      end

      def call
        rendered = helpers.govuk_tag(text: status[:text], colour: status[:colour])
        rendered += unpublished_hint if has_unpublished_changes?
        rendered
      end

    private

      attr_reader :course, :recruitment_cycle_year

      def status
        status_tags.fetch(content_status.to_sym)
      end

      def status_tags
        if current_or_previous_cycle?
          course.application_status_open? ? OPEN_APPLICATION_STATUS_TAGS : CLOSED_APPLICATION_STATUS_TAGS
        else
          SCHEDULED_STATUS_TAGS
        end
      end

      def current_or_previous_cycle?
        [Find::CycleTimetable.current_year, Find::CycleTimetable.previous_year].include?(recruitment_cycle_year.to_i)
      end

      def content_status
        course.read_attribute(:content_status)
      end

      def has_unpublished_changes?
        ActiveModel::Type::Boolean.new.cast(course.read_attribute(:has_unpublished_changes))
      end

      def unpublished_hint
        helpers.tag.span(
          "* Unpublished changes",
          class: "govuk-body-s govuk-!-display-block govuk-!-margin-bottom-0 govuk-!-margin-top-1",
        )
      end
    end
  end
end
