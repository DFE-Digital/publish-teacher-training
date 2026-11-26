# frozen_string_literal: true

module Support
  module Providers
    class HistoryQuery
      def self.call(provider:)
        new(provider:).call
      end

      def self.for(provider, search: nil)
        new(provider:, search:)
      end

      attr_reader :search

      def initialize(provider:, search: nil)
        @provider = provider
        @search = search.to_s.strip.presence
      end

      def call
        entries_for(audits_scope)
      end

      def audits_scope
        Audited::Audit
          .where(auditable_condition)
          .then { |audits| search ? audits.and(search_condition) : audits }
          .includes(:user)
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

      def search_condition
        audits = Audited::Audit
        course_ids = matched_course_ids

        audits.where(auditable_type: Course.name, auditable_id: course_ids)
          .or(audits.where(auditable_type: CourseEnrichment.name, associated_type: Course.name, associated_id: course_ids))
          .or(audits.where(user_type: User.name, user_id: User.search(search).reorder(nil).select(:id)))
      end

      def matched_course_ids
        term = search.downcase

        courses_by_id.values
          .select { |course| [course.name, course.course_code].any? { |value| value.to_s.downcase.include?(term) } }
          .map(&:id)
      end

      # Provider/course creates are excluded here so pagy only counts audits that
      # Entry will render. Enrichment creates are kept (e.g. rollover status).
      def auditable_condition
        [
          [
            provider_updates_sql,
            course_updates_sql,
            enrichment_status_sql,
          ].join(" OR "),
          {
            provider_type: Provider.name,
            provider_id: provider.id,
            course_type: Course.name,
            course_ids:,
            enrichment_type: CourseEnrichment.name,
            update: "update",
            provider_keys: keys_for("Provider"),
            course_keys: keys_for("Course"),
            status_key: History::Entry::CHANGE_TYPES.fetch(:enrichment_status).fetch(:key),
          },
        ]
      end

      def provider_updates_sql
        "auditable_type = :provider_type AND auditable_id = :provider_id AND " \
          "action = :update AND audited_changes ?| array[:provider_keys]"
      end

      def course_updates_sql
        "auditable_type = :course_type AND auditable_id IN (:course_ids) AND " \
          "action = :update AND audited_changes ?| array[:course_keys]"
      end

      def enrichment_status_sql
        "auditable_type = :enrichment_type AND associated_type = :course_type AND " \
          "associated_id IN (:course_ids) AND audited_changes ? :status_key"
      end

      def keys_for(auditable_type)
        History::Entry::CHANGE_TYPES
          .filter_map { |_type, definition| definition[:key] if definition[:auditable_type] == auditable_type }
      end

      def courses_by_id
        @courses_by_id ||= provider.courses.index_by(&:id)
      end

      def course_ids
        # `[0]` keeps `IN (:course_ids)` valid when the provider has no courses yet.
        @course_ids ||= courses_by_id.keys.presence || [0]
      end
    end
  end
end
