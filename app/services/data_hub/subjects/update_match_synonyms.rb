module DataHub
  module Subjects
    class UpdateMatchSynonyms
      attr_reader :match_synonyms

      def initialize(subject:, synonyms:, subjects_cache: SubjectsCache.new)
        @subject = subject
        @match_synonyms = Array(synonyms).compact_blank.uniq
        @subjects_cache = subjects_cache
      end

      def call
        @subject.update!(match_synonyms:)
        @subjects_cache.expire_cache
      end
    end
  end
end
