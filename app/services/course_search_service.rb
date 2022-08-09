class CourseSearchService
  include ServicePattern
  include CourseSearchOptions

  def initialize(
    filter:,
    sort: nil,
    course_scope: Course
  )
    @filter = filter || {}
    @course_scope = course_scope
    @sort = sort
  end

  def call
    scope = course_scope
    scope = scope.includes(
      :enrichments,
      :financial_incentives,
      course_subjects: [:subject],
      site_statuses: [:site],
      provider: %i[recruitment_cycle ucas_preferences],
    )
    scope = scope.with_salary if funding_filter_salary?
    scope = scope.with_qualifications(qualifications) if qualifications.any?
    scope = scope.with_vacancies if has_vacancies?

    if findable?
      scope = scope.joins("
        FULL OUTER JOIN (
          SELECT
          course_id,
          array_remove(array_agg(cs.status = 'R' AND cs.publish = 'Y'), NULL) AS findables
          FROM course_site AS cs
          GROUP BY cs.course_id) AS findable_site_statuses ON findable_site_statuses.course_id = course.id
        "
      )

      scope = scope.where("? = ANY(findable_site_statuses.findables)", true)
    end

    scope = scope.with_study_modes(study_types) if study_types.any?

    if subject_codes.any?
      scope = scope.joins("
        FULL OUTER JOIN (
          SELECT
          course_id,
          array_remove(array_agg(s.subject_code), NULL) AS subject_codes
          FROM course_subject AS cs
          INNER JOIN subject AS s
              ON s.id = cs.subject_id
          GROUP BY cs.course_id) AS subjects ON subjects.course_id = course.id
        "
      )
      first_subject_code, *rest_subject_codes = subject_codes
      scope = scope.where("? = ANY(subjects.subject_codes)", first_subject_code)

      rest_subject_codes.each do |subject_code|
        scope = scope.or(scope.where("? = ANY(subjects.subject_codes)", subject_code))
      end
    end
    scope = scope.with_provider_name(provider_name) if provider_name.present?
    scope = scope.with_send if send_courses_filter?
    scope = scope.within(filter[:radius], origin:) if locations_filter?
    scope = scope.with_funding_types(funding_types) if funding_types.any?
    scope = scope.with_degree_grades(degree_grades) if degree_grades.any?
    scope = scope.changed_since(filter[:updated_since]) if updated_since_filter?
    scope = scope.provider_can_sponsor_visa if can_sponsor_visa_filter?

    if provider_name.present?
      scope = scope
                      .accredited_body_order(provider_name)
                      .ascending_canonical_order
    elsif sort_by_provider_ascending?
      scope = scope.ascending_canonical_order
      scope = scope.select("provider.provider_name", "course.*")
    elsif sort_by_provider_descending?
      scope = scope.descending_canonical_order
      scope = scope.select("provider.provider_name", "course.*")
    elsif sort_by_distance?
      scope = scope.joins(courses_with_distance_from_origin)
      scope = scope.joins(:provider)
      scope = scope.select("course.*, distance, #{Course.sanitize_sql(distance_with_university_area_adjustment)}")

      scope =
        if expand_university?
          scope.order(:boosted_distance)
        else
          scope.order(:distance)
        end
    end

    scope
  end

  private_class_method :new

private

  def distance_with_university_area_adjustment
    university_provider_type = Provider.provider_types[:university]
    university_location_area_radius = 10
    <<~EOSQL.gsub(/\s+/m, " ").strip
      (CASE
        WHEN provider.provider_type = '#{university_provider_type}'
          THEN (distance - #{university_location_area_radius})
        ELSE distance
      END) as boosted_distance
    EOSQL
  end

  def locatable_sites
    site_statuses = SiteStatus.arel_table
    sites = Site.arel_table

    # Create virtual table with sites and site statuses
    site_statuses.join(sites).on(site_statuses[:site_id].eq(sites[:id]))
     .where(site_statuses_criteria(site_statuses))
     .where(has_been_geocoded_criteria(sites))
     .where(locatable_address_criteria(sites))
  end

  def site_statuses_criteria(site_statuses)
    # Only running and published site statuses
    running_and_published_criteria = site_statuses[:status].eq(SiteStatus.statuses[:running]).and(site_statuses[:publish].eq(SiteStatus.publishes[:published]))

    if has_vacancies?
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

  def has_been_geocoded_criteria(sites)
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
    origin_lat_long = Struct.new(:lat, :lng).new(origin[0].to_f, origin[1].to_f)
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

  attr_reader :course_scope
end
