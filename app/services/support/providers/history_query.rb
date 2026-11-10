# frozen_string_literal: true

module Support
  module Providers
    class HistoryQuery
      RELEVANT_KEYS = %w[
        provider_name
        provider_code
        name
        application_status
        status
      ].freeze

      def self.call(provider:)
        new(provider:).call
      end

      def self.for(provider)
        new(provider:)
      end

      def initialize(provider:)
        @provider = provider
      end

      def call
        entries_for(audits_scope)
      end

      def audits_scope
        Audited::Audit
          .includes(:user)
          .where(auditable_condition)
          .where("audited_changes ?| array[:keys]", keys: RELEVANT_KEYS)
          .order(created_at: :desc, id: :desc)
      end

      def entries_for(audits)
        courses_by_id
        enrichments_by_id

        audits.flat_map do |audit|
          History::Entry.entries_for(
            audit:,
            courses_by_id:,
            enrichments_by_id:,
          )
        end
      end

    private

      attr_reader :provider

      def auditable_condition
        [
          "(auditable_type = :provider_type AND auditable_id = :provider_id) OR " \
          "(auditable_type = :course_type AND auditable_id IN (:course_ids)) OR " \
          "(auditable_type = :enrichment_type AND auditable_id IN (:enrichment_ids))",
          {
            provider_type: Provider.name,
            provider_id: provider.id,
            course_type: Course.name,
            course_ids: course_ids,
            enrichment_type: CourseEnrichment.name,
            enrichment_ids: enrichment_ids,
          },
        ]
      end

      def courses_by_id
        @courses_by_id ||= provider.courses.index_by(&:id)
      end

      def enrichments_by_id
        @enrichments_by_id ||= CourseEnrichment.where(course_id: course_ids).index_by(&:id)
      end

      def course_ids
        @course_ids ||= courses_by_id.keys.presence || [0]
      end

      def enrichment_ids
        @enrichment_ids ||= enrichments_by_id.keys.presence || [0]
      end
    end
  end
end
