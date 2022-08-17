module Courses
  class ContentStatusService
    def execute(enrichment:, recruitment_cycle:)
      return :rolled_over if (recruitment_cycle.next? && enrichment.blank?) || enrichment&.rolled_over?
      return :published if enrichment&.published?
      return :withdrawn if enrichment&.withdrawn?
      return :published_with_unpublished_changes if enrichment&.has_been_published_before?

      :draft
    end
  end
end
