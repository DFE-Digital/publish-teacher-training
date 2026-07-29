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
      return :published if enrichment&.has_been_published_before? || (enrichment&.course&.enrichments&.most_recent.present? && enrichment&.course&.enrichments&.many?)

      :draft
    end
  end
end
