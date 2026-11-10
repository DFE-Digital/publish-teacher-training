# frozen_string_literal: true

module Support
  module Providers
    class HistoryQuery
      PROVIDER_KEYS = %w[provider_name provider_code].freeze
      COURSE_KEYS = %w[name application_status].freeze

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
          .order(created_at: :desc, id: :desc)
      end

      def entries_for(audits)
        audits.flat_map do |audit|
          History::Entry.entries_for(
            audit:,
            courses_by_id:,
          )
        end
      end

    private

      attr_reader :provider

      # Provider/course creates are excluded here so pagy only counts audits that
      # Entry will render. Enrichment creates are kept (e.g. rollover status).
      def auditable_condition
        [
          "(auditable_type = :provider_type AND auditable_id = :provider_id AND action = :update AND audited_changes ?| array[:provider_keys]) OR " \
          "(auditable_type = :course_type AND auditable_id IN (:course_ids) AND action = :update AND audited_changes ?| array[:course_keys]) OR " \
          "(auditable_type = :enrichment_type AND associated_type = :course_type AND associated_id IN (:course_ids) AND audited_changes ? :status_key)",
          {
            provider_type: Provider.name,
            provider_id: provider.id,
            course_type: Course.name,
            course_ids:,
            enrichment_type: CourseEnrichment.name,
            update: "update",
            provider_keys: PROVIDER_KEYS,
            course_keys: COURSE_KEYS,
            status_key: "status",
          },
        ]
      end

      def courses_by_id
        @courses_by_id ||= provider.courses.index_by(&:id)
      end

      def course_ids
        @course_ids ||= courses_by_id.keys.presence || [0]
      end
    end
  end
end
