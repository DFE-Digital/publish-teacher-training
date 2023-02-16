# frozen_string_literal: true

class CourseSearchService
  include ServicePattern

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
    scope = scope.with_salary if funding_filter_salary?
    scope = scope.with_qualifications(qualifications) if qualifications.any?
    scope = scope.with_vacancies if has_vacancies?
    scope = scope.findable if findable?
    scope = scope.with_study_modes(study_types) if study_types.any?
    scope = scope.with_subjects(subject_codes) if subject_codes.any?
    scope = scope.with_provider_name(provider_name) if provider_name.present?
    scope = scope.with_send if send_courses_filter?
    scope = scope.within(filter[:radius], origin:) if locations_filter?
    scope = scope.with_funding_types(funding_types) if funding_types.any?
    scope = scope.with_degree_grades(degree_grades_accepted) if degrees_accepted?
    scope = scope.with_degree_grades(degree_grades) if degree_grades.any?
    scope = scope.changed_since(filter[:updated_since]) if updated_since_filter?
    scope = scope.can_sponsor_visa if can_sponsor_visa_filter?
    scope = scope.engineers_teach_physics if engineers_teach_physics_filter?

    # The 'where' scope will remove duplicates
    # An outer query is required in the event the provider name is present.
    # This prevents 'PG::InvalidColumnReference: ERROR: for SELECT DISTINCT, ORDER BY expressions must appear in select list'
    outer_scope = Course.includes(
      :enrichments,
      :financial_incentives,
      course_subjects: [:subject],
      site_statuses: [:site],
      provider: %i[recruitment_cycle ucas_preferences]
    ).where(id: scope.select(:id))

    if provider_name.present?
      outer_scope = outer_scope
                    .accredited_body_order(provider_name)
                    .ascending_provider_canonical_order
    elsif sort_by_provider_ascending?
      outer_scope = outer_scope.ascending_provider_canonical_order
      outer_scope = outer_scope.select('provider.provider_name', 'course.*')
    elsif sort_by_provider_descending?
      outer_scope = outer_scope.descending_provider_canonical_order
      outer_scope = outer_scope.select('provider.provider_name', 'course.*')
    elsif sort_by_course_ascending?
      outer_scope = outer_scope.ascending_course_canonical_order
    elsif sort_by_course_descending?
      outer_scope = outer_scope.descending_course_canonical_order
    elsif sort_by_distance?
      outer_scope = outer_scope.joins(courses_with_distance_from_origin)
      outer_scope = outer_scope.joins(:provider)
      outer_scope = outer_scope.select("course.*, distance, #{Course.sanitize_sql(distance_with_university_area_adjustment)}")

      outer_scope =
        if expand_university?
          outer_scope.order(:boosted_distance)
        else
          outer_scope.order(:distance)
        end
    end

    outer_scope
  end

  private_class_method :new

  private

  def expand_university?
    filter[:expand_university].to_s.downcase == 'true'
  end

  def distance_with_university_area_adjustment
    university_provider_type = Provider.provider_types[:university]
    university_location_area_radius = 10
    <<~EOSQL.gsub(/\s+/m, ' ').strip
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
                  SiteStatus.vac_statuses[:both_full_time_and_part_time_vacancies]
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
    sites[:address1].not_eq('').or(sites[:postcode].not_eq(''))
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
        format('(%s)', course_id_with_lowest_locatable_distance.to_sql)
      ), 'distances'
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

  def sort_by_course_ascending?
    sort == 'course_asc' || course_asc_requirement
  end

  def sort_by_course_descending?
    sort == 'course_desc' || course_desc_requirement
  end

  def sort_by_provider_ascending?
    sort == 'provider_asc' || provider_asc_requirement
  end

  def sort_by_provider_descending?
    sort == 'provider_desc' || provider_desc_requirement
  end

  def sort_by_distance?
    sort == 'distance'
  end

  def origin
    [filter[:latitude], filter[:longitude]]
  end

  attr_reader :sort, :filter, :course_scope

  def funding_filter_salary?
    filter[:funding] == 'salary'
  end

  def qualifications
    return [] if filter[:qualification].blank?

    filter[:qualification] = filter[:qualification].values if filter[:qualification].is_a?(Hash)
    filter[:qualification] = filter[:qualification].split(',') if filter[:qualification].is_a?(String)

    if filter[:qualification].include?('pgce pgde')
      filter[:qualification] -= ['pgce pgde']
      filter[:qualification] |= %w[pgce pgde]
    end

    filter[:qualification] |= %w[pgde_with_qts] if filter[:qualification].is_a?(Array) && filter[:qualification].include?('pgce_with_qts')

    filter[:qualification]
  end

  def has_vacancies?
    filter[:has_vacancies].to_s.downcase == 'true'
  end

  def findable?
    filter[:findable].to_s.downcase == 'true'
  end

  def study_types
    # this passes for strings and arrays
    return [] if filter[:study_type].blank?
    return filter[:study_type] if filter[:study_type].is_a? Array

    filter[:study_type].split(',')
  end

  def funding_types
    return [] if filter[:funding_type].blank?

    filter[:funding_type].split(',')
  end

  def degrees_accepted?
    filter[:degree_required].present?
  end

  def degree_grades_accepted
    return [] unless degrees_accepted?

    degree_required_parameter = filter[:degree_required].to_sym

    accepted_degrees = {
      show_all_courses: 'two_one,two_two,third_class,not_required',
      two_two: 'two_two,third_class,not_required',
      third_class: 'third_class,not_required',
      not_required: 'not_required'
    }

    accepted_degrees[degree_required_parameter].split(',')
  end

  def degree_grades
    return [] if filter[:degree_grade].blank?
    return [] unless filter[:degree_grade].is_a?(String)

    filter[:degree_grade].split(',')
  end

  def subject_codes
    return [] if filter[:subjects].blank?
    return filter[:subjects] if filter[:subjects].is_a? Array
    return filter[:subjects].values if filter[:subjects].is_a?(Hash)

    filter[:subjects].split(',')
  end

  def provider_name
    return [] if filter[:'provider.provider_name'].blank?

    filter[:'provider.provider_name']
  end

  def send_courses_filter?
    filter[:send_courses].to_s.downcase == 'true'
  end

  def updated_since_filter?
    filter[:updated_since].present?
  end

  def can_sponsor_visa_filter?
    filter[:can_sponsor_visa].to_s.downcase == 'true'
  end

  def engineers_teach_physics_filter?
    filter[:engineers_teach_physics].to_s.downcase == 'true' || filter[:campaign_name] == 'engineers_teach_physics'
  end

  def course_asc_requirement
    sort == 'name,provider.provider_name'
  end

  def course_desc_requirement
    sort == '-name,provider.provider_name'
  end

  def provider_asc_requirement
    sort == 'provider.provider_name,name'
  end

  def provider_desc_requirement
    sort == '-provider.provider_name,name'
  end
end
