# frozen_string_literal: true

module Enrichments
  class CopyToCourseService
    def execute(enrichment:, new_course:)
      new_enrichment = enrichment.dup
      new_enrichment.last_published_timestamp_utc = nil
      # Assign status before the first save so the create audit is associated
      # with new_course rather than the source course from dup.
      new_enrichment.status = :rolled_over
      new_course.enrichments << new_enrichment
    end
  end
end
