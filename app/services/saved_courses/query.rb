# frozen_string_literal: true

module SavedCourses
  class Query < Courses::Query
    def self.call(candidate:, params: {})
      new(candidate:, params:).call
    end

    def initialize(candidate:, params: {}) # rubocop:disable Lint/MissingSuper
      @params = params
      @applied_scopes = {}
      @scope = candidate
        .saved_courses_without_withdrawn
        .joins(course: :provider)
    end

    def call
      @scope = location_scope
      @scope = default_ordering_scope
      @scope = distance_ascending_order_scope
      @scope = newest_first_order_scope
      @scope = fee_uk_ascending_order_scope
      @scope = fee_intl_ascending_order_scope
      @scope = preload_scope
      @scope
    end

  private

    def location_scope
      return @scope if params[:latitude].blank? || params[:longitude].blank?

      latitude = Float(params[:latitude])
      longitude = Float(params[:longitude])

      @applied_scopes[:location] = { latitude:, longitude:, radius: radius_in_miles }

      if FeatureFlag.active?(:course_publishing_uses_new_school_model)
        schools_location_scope(latitude:, longitude:)
      else
        sites_location_scope(latitude:, longitude:)
      end
    end

    # Distance annotation over the legacy course_site -> site model, used while
    # the :course_publishing_uses_new_school_model flag is off. Saved courses are
    # annotated with distance but not filtered by radius. Previous-cycle courses
    # are retained when their old placement sites are no longer publishable.
    # Both latitude and longitude are required to compute distance.
    def sites_location_scope(latitude:, longitude:)
      @scope
        .joins(<<~SQL)
          LEFT JOIN course_site ON (
            course_site.course_id = course.id
            AND course_site.status = 'R'
            AND course_site.publish = 'Y'
          )
          LEFT JOIN site ON (
            site.id = course_site.site_id
            AND site.discarded_at IS NULL
            AND site.longitude IS NOT NULL
            AND site.latitude IS NOT NULL
          )
        SQL
        .where("site.id IS NOT NULL OR provider.recruitment_cycle_id <> ?", current_recruitment_cycle_id)
        .select(
          Course.sanitize_sql_array(
            [
              <<~SQL.squish,
                saved_course.*,
                MIN(ST_DistanceSphere(
                  ST_SetSRID(ST_MakePoint(site.longitude::float, site.latitude::float), 4326),
                  ST_SetSRID(ST_MakePoint(?::float, ?::float), 4326)
                ) / 1609.344) AS minimum_distance_to_search_location
              SQL
              longitude,
              latitude,
            ],
          ),
        )
        .group("saved_course.id, provider.provider_name")
    end

    # Distance annotation over the canonical course_school -> gias_school model,
    # used while the :course_publishing_uses_new_school_model flag is on. As with
    # the legacy path, saved courses are annotated with distance but not filtered
    # by radius. Previous-cycle courses are retained when they have no canonical
    # school with coordinates.
    def schools_location_scope(latitude:, longitude:)
      @scope
        .joins(<<~SQL)
          LEFT JOIN course_school ON course_school.course_id = course.id
          LEFT JOIN gias_school ON (
            gias_school.id = course_school.gias_school_id
            AND gias_school.latitude IS NOT NULL
            AND gias_school.longitude IS NOT NULL
          )
        SQL
        .where("gias_school.id IS NOT NULL OR provider.recruitment_cycle_id <> ?", current_recruitment_cycle_id)
        .select(
          Course.sanitize_sql_array(
            [
              <<~SQL.squish,
                saved_course.*,
                MIN(ST_DistanceSphere(
                  ST_SetSRID(ST_MakePoint(gias_school.longitude::float, gias_school.latitude::float), 4326),
                  ST_SetSRID(ST_MakePoint(?::float, ?::float), 4326)
                ) / 1609.344) AS minimum_distance_to_search_location
              SQL
              longitude,
              latitude,
            ],
          ),
        )
        .group("saved_course.id, provider.provider_name")
    end

    def default_order_name
      @applied_scopes[:location].present? ? "distance" : "newest_first"
    end

    # Override: fall back to newest_first when distance is requested
    # but no location was provided (the column doesn't exist without location_scope).
    def distance_ascending_order_scope
      return @scope unless params[:order] == "distance"

      if @applied_scopes[:location].blank?
        params[:order] = "newest_first"
        return @scope
      end

      @applied_scopes[:order] = params[:order]

      @scope.order("minimum_distance_to_search_location ASC, LOWER(provider.provider_name) ASC")
    end

    def newest_first_order_scope
      return @scope unless params[:order] == "newest_first"

      @applied_scopes[:order] = params[:order]

      @scope.order("saved_course.created_at DESC")
    end

    # Override: select saved_course.* instead of course.* and adjust GROUP BY
    # so SavedCourse attributes (like course_id) are available on the result.
    #
    # LEFT JOIN keeps previous-cycle courses that have no published enrichment.
    # Current-cycle courses still need one. When a previous-cycle course does
    # have a published enrichment, the lateral join still uses it for sorting.
    def fee_uk_ascending_order_scope
      return @scope unless params[:order] == "fee_uk_ascending"

      @applied_scopes[:order] = params[:order]

      @scope
        .select("saved_course.*, #{funding_sorting}, provider.provider_name, MAX((course_enrichment.json_data->>'FeeUkEu')::integer) as uk_fee")
        .joins(latest_published_enrichment_join_sql(join_type: "LEFT"))
        .where("course_enrichment.id IS NOT NULL OR provider.recruitment_cycle_id <> ?", current_recruitment_cycle_id)
        .group("saved_course.id, course.id, provider.id, provider.provider_name")
        .order(
          {
            "fee_funding" => :asc,
            "uk_fee" => :asc,
            courses_table[:name] => :asc,
            providers_table[:provider_name] => :asc,
            courses_table[:course_code] => :asc,
          },
        )
    end

    def fee_intl_ascending_order_scope
      return @scope unless params[:order] == "fee_intl_ascending"

      @applied_scopes[:order] = params[:order]

      @scope
        .select("saved_course.*, #{funding_sorting}, provider.provider_name, MAX((course_enrichment.json_data->>'FeeInternational')::integer) as intl_fee")
        .joins(latest_published_enrichment_join_sql(join_type: "LEFT"))
        .where("course_enrichment.id IS NOT NULL OR provider.recruitment_cycle_id <> ?", current_recruitment_cycle_id)
        .group("saved_course.id, course.id, provider.id, provider.provider_name")
        .order(
          {
            "fee_funding" => :asc,
            "intl_fee" => :asc,
            courses_table[:name] => :asc,
            providers_table[:provider_name] => :asc,
            courses_table[:course_code] => :asc,
          },
        )
    end

    def preload_scope
      @scope.preload(
        course: [
          :latest_published_enrichment,
          { provider: :recruitment_cycle },
          { subjects: [:financial_incentive] },
        ],
      )
    end

    def current_recruitment_cycle_id
      @current_recruitment_cycle_id ||= RecruitmentCycle.current_recruitment_cycle!.id
    end
  end
end
