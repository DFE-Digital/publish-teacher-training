module DataHub
  module Subjects
    class AddMatchSynonyms
      def initialize(subject:, synonyms:, subjects_cache: SubjectsCache.new)
        @subject = subject
        @synonyms = Array(synonyms).compact_blank
        @subjects_cache = subjects_cache
      end

      def call
        return if @synonyms.empty?

        existing_synonyms = Array(@subject.match_synonyms)
        updated_synonyms = (existing_synonyms + @synonyms).uniq

        @subject.update!(match_synonyms: updated_synonyms)
        @subjects_cache.expire_cache
      end
    end
  end
end
