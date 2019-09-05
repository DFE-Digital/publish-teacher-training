module Enrichments
  class CopyToCourseService
    def execute(enrichment:, new_course:)
      new_enrichment = enrichment.dup
      new_enrichment.last_published_timestamp_utc = nil
      new_enrichment.rolled_over!
      new_course.enrichments << new_enrichment
    end
  end
end
