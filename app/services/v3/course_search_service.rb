module V3
  class CourseSearchService
    def initialize(filter:, sort: nil, course_scope: Course)
      @filter = filter || {}
      @course_scope = course_scope
      @sort = Set.new(sort&.split(","))
    end

    class << self
      def call(**args)
        new(args).call
      end
    end

    def call
      scope = course_scope
      scope = scope.with_salary if funding_filter_salary?
      scope = scope.with_qualifications(qualifications) if qualifications.any?
      scope = scope.with_vacancies if with_vacancies?
      scope = scope.findable if findable?
      scope = scope.with_study_modes(study_types) if study_types.any?
      scope = scope.with_subjects(subject_codes) if subject_codes.any?
      scope = scope.with_provider_name(provider_name) if provider_name.present?
      scope = scope.with_send if send_courses_filter?
      scope = scope.within(filter[:radius], origin: origin) if locations_filter?
      scope = scope.with_funding_types(funding_types) if funding_types.any?
      scope = scope.with_degree_grades(degree_grades) if degree_grades.any?
      scope = scope.changed_since(filter[:updated_since]) if updated_since_filter?
      scope = scope.provider_can_sponsor_visa if can_sponsor_visa_filter?

      # The 'where' scope will remove duplicates
      # An outer query is required in the event the provider name is present.
      # This prevents 'PG::InvalidColumnReference: ERROR: for SELECT DISTINCT, ORDER BY expressions must appear in select list'
      outer_scope = Course.includes(
        :enrichments,
        :financial_incentives,
        course_subjects: [:subject],
        site_statuses: [:site],
        provider: %i[recruitment_cycle ucas_preferences],
      ).where(id: scope.select(:id))

      if provider_name.present?
        outer_scope = outer_scope
                        .accredited_body_order(provider_name)
                        .ascending_canonical_order
      elsif sort_by_provider_ascending?
        outer_scope = outer_scope.ascending_canonical_order
        outer_scope = outer_scope.select("provider.provider_name", "course.*")
      elsif sort_by_provider_descending?
        outer_scope = outer_scope.descending_canonical_order
        outer_scope = outer_scope.select("provider.provider_name", "course.*")
      elsif sort_by_distance?
        outer_scope = outer_scope.joins(courses_with_distance_from_origin)
        outer_scope = outer_scope.joins(:provider)
        outer_scope = outer_scope.select("course.*, distance")
        outer_scope.order(:distance)
      end

      outer_scope
    end

    private_class_method :new

  private

    def locatable_sites
      site_statuses = SiteStatus.arel_table
      sites = Site.arel_table

      # Create virtual table with sites and site statuses
      site_statuses.join(sites).on(site_statuses[:site_id].eq(sites[:id]))
      .where(site_statuses_criteria(site_statuses))
      .where(already_geocoded_criteria(sites))
      .where(locatable_address_criteria(sites))
    end

    def site_statuses_criteria(site_statuses)
      # Only running and published site statuses
      running_and_published_criteria = site_statuses[:status].eq(SiteStatus.statuses[:running]).and(site_statuses[:publish].eq(SiteStatus.publishes[:published]))

      if with_vacancies?
        # Only site statuses with vacancies
        running_and_published_criteria
          .and(site_statuses[:vac_status])
          .eq_any([
            SiteStatus.vac_statuses[:full_time_vacancies],
            SiteStatus.vac_statuses[:part_time_vacancies],
            SiteStatus.vac_statuses[:both_full_time_and_part_time_vacancies],
          ])
      else
        running_and_published_criteria
      end
    end

    def already_geocoded_criteria(sites)
      # we only want sites that have been geocoded
      sites[:latitude].not_eq(nil).and(sites[:longitude].not_eq(nil))
    end

    def locatable_address_criteria(sites)
      # only sites that have a locatable address
      # there are some sites with no address1 or postcode that cannot be
      # accurately geocoded. We don't want to return these as the closest site.
      # This should be removed once the data is fixed
      sites[:address1].not_eq("").or(sites[:postcode].not_eq(""))
    end

    def course_id_with_lowest_locatable_distance
      # select course_id and nearest site with shortest distance from origin
      # as courses may have multiple sites
      # this will remove duplicates by aggregating on course_id
      origin_lat_long = OpenStruct.new(lat: origin[0].to_f, lng: origin[1].to_f)
      lowest_locatable_distance = Arel.sql("MIN#{Site.sanitize_sql(Site.distance_sql(origin_lat_long))} as distance")
      locatable_sites.project(:course_id, lowest_locatable_distance).group(:course_id)
    end

    def distance_table
      # form a temporary table with results
      Arel::Nodes::TableAlias.new(
        Arel.sql(
          format("(%s)", course_id_with_lowest_locatable_distance.to_sql),
        ), "distances"
      )
    end

    def courses_with_distance_from_origin
      # grab courses table and join with the above result set
      # so distances from origin are now available
      # we can then sort by distance from the given origin
      courses_table = Course.arel_table
      courses_table.join(distance_table).on(courses_table[:id].eq(distance_table[:course_id])).join_sources
    end

    def locations_filter?
      filter.key?(:latitude) &&
        filter.key?(:longitude) &&
        filter.key?(:radius)
    end

    def sort_by_provider_ascending?
      sort == Set["name", "provider.provider_name"]
    end

    def sort_by_provider_descending?
      sort == Set["-name", "-provider.provider_name"]
    end

    def sort_by_distance?
      sort == Set["distance"]
    end

    def origin
      [filter[:latitude], filter[:longitude]]
    end

    attr_reader :sort, :filter, :course_scope

    def funding_filter_salary?
      filter[:funding] == "salary"
    end

    def qualifications
      return [] if filter[:qualification].blank?

      filter[:qualification].split(",")
    end

    def with_vacancies?
      filter[:has_vacancies].to_s.downcase == "true"
    end

    def findable?
      filter[:findable].to_s.downcase == "true"
    end

    def study_types
      return [] if filter[:study_type].blank?

      filter[:study_type].split(",")
    end

    def funding_types
      return [] if filter[:funding_type].blank?

      filter[:funding_type].split(",")
    end

    def degree_grades
      return [] if filter[:degree_grade].blank?

      filter[:degree_grade].split(",")
    end

    def subject_codes
      return [] if filter[:subjects].blank?

      filter[:subjects].split(",")
    end

    def provider_name
      return [] if filter[:"provider.provider_name"].blank?

      filter[:"provider.provider_name"]
    end

    def send_courses_filter?
      filter[:send_courses].to_s.downcase == "true"
    end

    def updated_since_filter?
      filter[:updated_since].present?
    end

    def can_sponsor_visa_filter?
      filter[:can_sponsor_visa].to_s.downcase == "true"
    end
  end
end
