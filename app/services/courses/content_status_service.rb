module Courses
  class ContentStatusService
    def execute(enrichment, next_cycle_boolean)
      if !enrichment.present?
        if next_cycle_boolean
          :rolled_over
        else
          :empty
        end
      elsif enrichment.published?
        :published
      elsif enrichment.withdrawn?
        :withdrawn
      elsif enrichment.has_been_published_before?
        :published_with_unpublished_changes
      elsif enrichment.rolled_over?
        :rolled_over
      else
        :draft
      end
    end
  end
end
