# frozen_string_literal: true

module Enrichments
  class CopyToCourseService
    def execute(enrichment:, new_course:)
      new_enrichment = enrichment.dup
      new_enrichment.last_published_timestamp_utc = nil
      # Assign the destination course before the first save so audited associates
      # the create with new_course, and so rolled_over! still raises on invalid data.
      new_enrichment.course = new_course
      new_enrichment.rolled_over!
    end
  end
end
