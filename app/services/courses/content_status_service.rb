# frozen_string_literal: true

module Courses
  class ContentStatusService
    def execute(enrichment:)
      return :rolled_over if enrichment&.rolled_over?
      return :published if enrichment&.published?
      return :withdrawn if enrichment&.withdrawn?
      # Subsequent drafts (published before, then edited) used to map to
      # published_with_unpublished_changes. Treat them as published so status
      # tags stay correct until the data migration deletes those drafts.
      # New edits no longer create this state.
      #
      # many? reads the loaded enrichments where the caller preloaded them;
      # the most_recent.present? this used to ask as well was a second query
      # for something many? already implies - we were handed an enrichment of
      # this course, so it has one.
      return :published if enrichment&.has_been_published_before? || enrichment&.course&.enrichments&.many?

      :draft
    end
  end
end
