# frozen_string_literal: true

module Publish
  module Courses
    # Builds the relation behind the publish course list. Modelled on
    # +Courses::Query+ (the Find search query): a base scope set in the
    # initializer, then scope methods chained in +#call+, each guarding on its
    # param and recording +applied_scopes+.
    #
    # The query returns each course pre-ordered for grouping (self-accredited
    # first, then accredited provider name, then course name/code) and decorated
    # with three computed columns so the list needs no enrichment or site rows:
    #
    # - +group_name+               the accredited provider heading (NULL = self-accredited)
    # - +content_status+           draft / published / withdrawn / rolled_over /
    #                              published_with_unpublished_changes
    # - +has_unpublished_changes+  boolean
    #
    # content_status and has_unpublished_changes are a SQL port of
    # +Courses::ContentStatusService+ and +Course#has_unpublished_changes?+; the
    # Ruby remains the source of truth and a cross-check spec asserts agreement.
    class Query
      # Ports Courses::ContentStatusService#execute. Held as a constant because
      # Postgres cannot reference a SELECT alias from WHERE, so the status filter
      # has to repeat the expression rather than reuse the +content_status+ column.
      CONTENT_STATUS_SQL = <<~SQL.squish
        CASE
          WHEN enrichment_stats.latest_status = 2 THEN 'rolled_over'
          WHEN enrichment_stats.latest_status = 1 THEN 'published'
          WHEN enrichment_stats.latest_status = 3 THEN 'withdrawn'
          WHEN enrichment_stats.latest_status IS NULL THEN 'draft'
          WHEN enrichment_stats.latest_published_at IS NOT NULL OR enrichment_stats.total > 1
            THEN 'published_with_unpublished_changes'
          ELSE 'draft'
        END
      SQL

      # Filter option -> Course enum keys. Both mirror Courses::Query (the Find
      # search query), except that selecting several options here unions them
      # rather than falling through to "no filter".
      QUALIFICATION_OPTIONS = {
        "qts" => %i[qts],
        "qts_with_pgce_or_pgde" => %i[pgce_with_qts pgde_with_qts],
      }.freeze

      STUDY_MODE_OPTIONS = {
        "full_time" => %i[full_time full_time_or_part_time],
        "part_time" => %i[part_time full_time_or_part_time],
      }.freeze

      def self.call(...)
        new(...).call
      end

      attr_reader :applied_scopes, :scope, :params

      def initialize(provider:, params: {})
        @provider = provider
        @params = params
        @applied_scopes = {}
        # Preload provider + cycle for the course link path and status cycle
        # branch; status/display fields come from columns (no enrichment/site loads).
        @scope = provider.courses.includes(provider: :recruitment_cycle)
      end

      def call
        @scope = accredited_provider_scope
        @scope = enrichment_join_scope
        @scope = level_scope
        @scope = funding_scope
        @scope = qualification_scope
        @scope = study_mode_scope
        @scope = status_columns_select
        @scope = ordering_scope
        @scope
      end

      def count
        @scope.unscope(:select, :order).distinct.count(:id)
      end

    private

      attr_reader :provider

      # Filter: restrict to courses ratified by a given accredited provider
      # (used by the training-partners course list).
      def accredited_provider_scope
        return @scope if params[:accredited_provider].blank?

        @applied_scopes[:accredited_provider] = params[:accredited_provider]
        @scope.where(accredited_provider_code: params[:accredited_provider])
      end

      # The provider-facing filter offers two qualification choices; the second
      # covers both of the postgraduate certificate/diploma qualifications.
      def qualification_scope
        return @scope if params[:qualification].blank?

        @applied_scopes[:qualification] = params[:qualification]
        keys = Array(params[:qualification]).flat_map { |option| QUALIFICATION_OPTIONS.fetch(option, []) }.uniq
        @scope.where(qualification: ::Course.qualifications.values_at(*keys))
      end

      # A course offered either way satisfies both the full time and the part
      # time filter, so each option matches its own mode plus the combined one.
      def study_mode_scope
        return @scope if params[:study_mode].blank?

        @applied_scopes[:study_mode] = params[:study_mode]
        keys = Array(params[:study_mode]).flat_map { |option| STUDY_MODE_OPTIONS.fetch(option, []) }.uniq
        @scope.where(study_mode: ::Course.study_modes.values_at(*keys))
      end

      def level_scope
        return @scope if params[:level].blank?

        @applied_scopes[:level] = params[:level]
        @scope.where(level: ::Course.levels.values_at(*Array(params[:level])).compact)
      end

      def funding_scope
        return @scope if params[:funding].blank?

        @applied_scopes[:funding] = params[:funding]
        @scope.where(funding: ::Course.fundings.values_at(*Array(params[:funding])).compact)
      end

      # Joins the accredited provider (for the heading) and a per-course aggregate
      # over its enrichments. Applied before the filter scopes, which need
      # enrichment_stats in scope; the matching SELECT comes after them.
      # course_enrichment.status enum: draft=0 published=1 rolled_over=2 withdrawn=3
      def enrichment_join_scope
        accredited_provider_join = sanitize(<<~SQL, cycle_id: provider.recruitment_cycle_id)
          LEFT OUTER JOIN provider accredited_provider
            ON accredited_provider.provider_code = course.accredited_provider_code
            AND accredited_provider.recruitment_cycle_id = :cycle_id
        SQL

        enrichment_stats_join = <<~SQL.squish
          LEFT JOIN LATERAL (
            SELECT
              COUNT(*) AS total,
              COUNT(*) FILTER (WHERE status = 1) AS published_count,
              COUNT(*) FILTER (WHERE status = 0) AS draft_count,
              COUNT(*) FILTER (WHERE status = 3) AS withdrawn_count,
              COUNT(*) FILTER (WHERE status IN (0, 2)) AS draft_or_rolled_count,
              MAX(last_published_timestamp_utc) AS max_published_at,
              (ARRAY_AGG(status ORDER BY created_at DESC, id DESC))[1] AS latest_status,
              (ARRAY_AGG(last_published_timestamp_utc ORDER BY created_at DESC, id DESC))[1] AS latest_published_at
            FROM course_enrichment
            WHERE course_enrichment.course_id = course.id
          ) enrichment_stats ON TRUE
        SQL

        @scope
          .joins(accredited_provider_join)
          .joins(enrichment_stats_join)
      end

      # Selects the computed columns the list renders from.
      def status_columns_select
        # NULL group name == self-accredited (rendered without a heading).
        group_name = sanitize(<<~SQL, own_code: provider.provider_code)
          CASE
            WHEN course.accredited_provider_code IS NULL OR course.accredited_provider_code = :own_code THEN NULL
            ELSE accredited_provider.provider_name
          END AS group_name
        SQL

        # Ports Course#has_unpublished_changes? (false when all enrichments are published).
        has_unpublished_changes = <<~SQL.squish
          (
            NOT (
              (enrichment_stats.total = 1 AND enrichment_stats.published_count >= 1)
              OR (enrichment_stats.draft_count = 0 AND enrichment_stats.withdrawn_count = 0)
            )
            AND (
              (enrichment_stats.published_count >= 1 AND enrichment_stats.draft_or_rolled_count >= 1)
              OR (enrichment_stats.max_published_at IS NOT NULL AND COALESCE(enrichment_stats.latest_status, -1) <> 3)
            )
          ) AS has_unpublished_changes
        SQL

        @scope.select("course.*", group_name, "#{CONTENT_STATUS_SQL} AS content_status", has_unpublished_changes)
      end

      # Self-accredited group first, then case-insensitive by accredited provider
      # name, then course name and code.
      def ordering_scope
        order_by = sanitize(<<~SQL.squish, own_code: provider.provider_code)
          CASE WHEN course.accredited_provider_code IS NULL OR course.accredited_provider_code = :own_code THEN 0 ELSE 1 END,
          LOWER(accredited_provider.provider_name),
          course.name,
          course.course_code
        SQL

        @scope.order(Arel.sql(order_by))
      end

      def sanitize(sql, **binds)
        ::Course.sanitize_sql_array([sql, binds])
      end
    end
  end
end
