# frozen_string_literal: true

module Enrichments
  class CopyToCourseService
    def execute(enrichment:, new_course:)
      new_enrichment = enrichment.dup
      new_json_data = new_enrichment.json_data.dup
      new_json_data.delete('PersonalQualities')
      new_json_data.delete('OtherRequirements')
      new_enrichment.json_data = new_json_data
      new_enrichment.last_published_timestamp_utc = nil
      new_enrichment.rolled_over!
      new_course.enrichments << new_enrichment
    end
  end
end
