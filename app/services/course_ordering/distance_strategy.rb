# frozen_string_literal: true

module CourseOrdering
  class DistanceStrategy < BaseStrategy
    UNIVERSITY_LOCATION_AREA_RADIUS = 10

    def order(scope)
      scope
        .joins(courses_with_distance_from_origin)
        .joins(:provider)
        .select("course.*, distance, #{Course.sanitize_sql(distance_with_university_area_adjustment)}")
        .order(expand_university? ? :boosted_distance : :distance)
    end

    def distance_with_university_area_adjustment
      university_provider_type = Provider.provider_types[:university]
      <<~EOSQL.gsub(/\s+/m, ' ').strip
        (CASE
          WHEN provider.provider_type = '#{university_provider_type}'
            THEN (distance - #{UNIVERSITY_LOCATION_AREA_RADIUS})
          ELSE distance
        END) as boosted_distance
      EOSQL
    end

    def courses_with_distance_from_origin
      # grab courses table and join with the above result set
      # so distances from origin are now available
      # we can then sort by distance from the given origin
      courses_table = Course.arel_table
      courses_table.join(distance_table).on(courses_table[:id].eq(distance_table[:course_id])).join_sources
    end

    def distance_table
      # form a temporary table with results
      Arel::Nodes::TableAlias.new(
        Arel.sql(
          format('(%s)', course_id_with_lowest_locatable_distance.to_sql)
        ), 'distances'
      )
    end

    def course_id_with_lowest_locatable_distance
      # select course_id and nearest site with shortest distance from origin
      # as courses may have multiple sites
      # this will remove duplicates by aggregating on course_id
      origin_lat_long = Struct.new(:latitude, :longitude).new(origin[0].to_f, origin[1].to_f)
      lowest_locatable_distance = Arel.sql("MIN#{Site.sanitize_sql(Site.distance_sql(origin_lat_long))} as distance")
      locatable_sites.project(:course_id, lowest_locatable_distance).group(:course_id)
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

    private

    def origin
      [filter[:latitude], filter[:longitude]]
    end

    def expand_university?
      filter[:expand_university].to_s.downcase == 'true'
    end

    def has_vacancies?
      filter[:has_vacancies].to_s.downcase == 'true'
    end
  end
end
