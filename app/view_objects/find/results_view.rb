require 'geokit'
module Find
  class ResultsView
    include ActionView::Helpers::NumberHelper

    MAXIMUM_NUMBER_OF_SUBJECTS = 43
    DISTANCE = '2'.freeze
    SUGGESTED_SEARCH_THRESHOLD = 3
    MAXIMUM_NUMBER_OF_SUGGESTED_LINKS = 2
    RESULTS_PER_PAGE = 30
    MILES = '50'.freeze

    def initialize(query_parameters:)
      @query_parameters = query_parameters
    end

    def query_parameters_with_defaults
      query_parameters.except('utf8', 'authenticity_token')
        .merge(qualifications_parameters)
        .merge(fulltime_parameters)
        .merge(parttime_parameters)
        .merge(hasvacancies_parameters)
        .merge(sen_courses_parameters)
        .merge(subject_parameters)
    end

    def filter_params_for(path)
      if devolved_nation?
        stripped_devolved_nation_params(path)
      else
        filter_params_with_unescaped_commas(path)
      end
    end

    def filter_params_with_unescaped_commas(base_path, parameters: query_parameters_with_defaults)
      UnescapedQueryStringService.call(base_path:, parameters:)
    end

    def stripped_devolved_nation_params(path)
      parameters = query_parameters_with_defaults.except('c', 'lat', 'long', 'loc', 'lq', 'l')
      filter_params_with_unescaped_commas(path, parameters:)
    end

    def fulltime?
      return false if query_parameters['fulltime'].nil?

      query_parameters['fulltime'] == 'true'
    end

    def parttime?
      return false if query_parameters['parttime'].nil?

      query_parameters['parttime'] == 'true'
    end

    def degree_required?
      query_parameters['degree_required'].present? && query_parameters['degree_required'] != 'show_all_courses'
    end

    def hasvacancies?
      return true if query_parameters['hasvacancies'].nil?

      query_parameters['hasvacancies'] == 'true'
    end

    def sen_courses?
      query_parameters['senCourses'] == 'true'
    end

    def qts_only?
      qualifications.include?('QtsOnly')
    end

    def pgce_or_pgde_with_qts?
      qualifications.include?('PgdePgceWithQts')
    end

    def other_qualifications?
      qualifications.include?('Other')
    end

    def all_qualifications?
      qts_only? && pgce_or_pgde_with_qts? && other_qualifications?
    end

    def with_salaries?
      query_parameters['funding'] == '8'
    end

    def send_courses?
      query_parameters['senCourses'].present? && query_parameters['senCourses'].downcase == 'true'
    end

    def visa_courses?
      query_parameters['can_sponsor_visa'].present? && query_parameters['can_sponsor_visa'].downcase == 'true'
    end

    def number_of_extra_subjects
      return 37 if number_of_subjects_selected == MAXIMUM_NUMBER_OF_SUBJECTS

      number_of_subjects_selected
    end

    def location
      query_parameters['loc'] || 'Across England'
    end

    def radius
      MILES
    end

    def sort_by
      query_parameters['sortby']
    end

    def show_map?
      latitude.present? && longitude.present?
    end

    def map_image_url
      "#{Settings.google.maps_api_url}\
  ?key=#{Settings.google.maps_api_key}\
  &center=#{latitude},#{longitude}\
  &zoom=#{google_map_zoom}\
  &size=300x200\
  &scale=2\
  &markers=#{latitude},#{longitude}"
    end

    def provider
      query_parameters['query']
    end

    def location_filter?
      query_parameters['l'] == '1'
    end

    def england_filter?
      query_parameters['l'] == '2'
    end

    def provider_filter?
      query_parameters['l'] == '3'
    end

    def location_search
      query_parameters['lq']
    end

    def sort_by_distance?
      sort_by == DISTANCE
    end

    def sort_options
      [
        ['Training provider (A-Z)', 0, { 'data-qa': 'sort-form__options__ascending' }],
        ['Training provider (Z-A)', 1, { 'data-qa': 'sort-form__options__descending' }],
      ]
    end

    def courses
      @courses ||= begin
        base_query = course_query(include_location: location_filter?)

        base_query = if sort_by_distance?
                      base_query.order(:distance)
                    else
                      base_query
                        .order('provider.provider_name': results_order)
                        .order(name: results_order)
                    end

        base_query
          .page(query_parameters[:page] || 1)
          .per(results_per_page)
      end
    end

    def course_count
      courses.meta['count']
    end

    def total_pages
      (course_count.to_f / results_per_page).ceil
    end

    def site_distance(course)
      distances = new_or_running_sites_with_vacancies_for(course).map do |site|
        lat_long.distance_to("#{site[:latitude]},#{site[:longitude]}")
      end

      min_distance = distances.min

      if min_distance && min_distance < 0.05
        min_distance.ceil(1)
      elsif min_distance && min_distance < 1
        min_distance.round(1)
      else
        min_distance.round(0)
      end
    end

    def nearest_address(course)
      nearest_address = nearest_location(course)

      [
        nearest_address.address1,
        nearest_address.address2,
        nearest_address.address3,
        nearest_address.address4,
        nearest_address.postcode,
      ].select(&:present?).join(', ').html_safe
    end

    def has_sites?(course)
      !new_or_running_sites_with_vacancies_for(course).empty?
    end

    def sites_count(course)
      new_or_running_sites_with_vacancies_for(course).count
    end

    def nearest_location_name(course)
      nearest_location(course).location_name
    end

    def subjects
      subject_codes.any? ? filtered_subjects : all_subjects
    end

    def all_subjects
      @all_subjects ||= Subject.select(:subject_name, :subject_code).order(:subject_name).all
    end

    def suggested_search_visible?
      course_count < SUGGESTED_SEARCH_THRESHOLD && suggested_search_links.any? && !devolved_nation?
    end

    def suggested_search_links
      all_links = []

      if with_salaries?
        first_link = suggested_search_link_including_unsalaried(current_radius: radius)
        all_links << first_link if first_link.present?
      end

      radii_for_suggestions.each do |radius|
        break if filter_links(all_links).count == 2

        all_links << SuggestedSearchLink.new(
          radius:,
          count: course_counter(radius_to_check: radius),
          parameters: query_parameters_with_defaults,
          explicit_salary_filter: with_salaries?,
        )
      end

      @suggested_search_links ||= filter_links(all_links)
    end

    def no_results_found?
      course_count.zero?
    end

    def has_results?
      course_count.positive?
    end

    def number_of_courses_string
      case course_count
      when 0
        'No courses'
      when 1
        '1 course'
      else
        "#{number_with_delimiter(course_count)} courses"
      end
    end

    def courses_empty?
      course_count.zero?
    end

    def placement_schools_summary(course)
      site_distance = site_distance(course)

      if site_distance < 11
        'Placement schools are near you'
      elsif site_distance < 21
        'Placement schools might be near you'
      else
        'Placement schools might be in commuting distance'
      end
    end

    def country
      query_parameters['c']
    end

    def devolved_nation?
      DEVOLVED_NATIONS.include?(country)
    end

  private

    def nearest_location(course)
      new_or_running_sites_with_vacancies_for(course).min_by do |site|
        lat_long.distance_to("#{site[:latitude]},#{site[:longitude]}")
      end
    end

    def results_per_page
      RESULTS_PER_PAGE
    end

    def qualification
      qualification = []
      qualification |= %w[qts] if qts_only?
      qualification |= %w[pgce_with_qts pgde_with_qts] if pgce_or_pgde_with_qts?
      qualification |= %w[pgce pgde] if other_qualifications?

      qualification
    end

    def new_or_running_sites_with_vacancies_for(course)
      sites = course
        .site_statuses
        .select(&:new_or_running?)
        .select(&:has_vacancies?)
        .map(&:site)
        .reject do |site|
          # Sites that have no address details whatsoever are not to be considered
          # when calculating '#nearest_address' or '#site_distance'
          [site.address1, site.address2, site.address3, site.address4, site.postcode].all?(&:blank?)
        end

      sites.reject do |site|
        site.latitude.blank? || site.longitude.blank?
      end
    end

    def lat_long
      Geokit::LatLng.new(latitude.to_f, longitude.to_f)
    end

    attr_reader :query_parameters

    def results_order
      return :desc if query_parameters[:sortby] == '1'

      :asc
    end

    def qualifications_parameters
      { 'qualifications' => query_parameters['qualifications'].presence || %w[QtsOnly PgdePgceWithQts Other] }
    end

    def fulltime_parameters
      { 'fulltime' => fulltime? }
    end

    def parttime_parameters
      { 'parttime' => parttime? }
    end

    def hasvacancies_parameters
      { 'hasvacancies' => hasvacancies? }
    end

    def sen_courses_parameters
      { 'senCourses' => sen_courses? }
    end

    def subject_parameters
      query_parameters['subject_codes'].present? ? { 'subject_codes' => query_parameters['subject_codes'].presence } : {}
    end

    def subject_parameters_array
      query_parameters['subject_codes'] || []
    end

    def subject_codes
      query_parameters['subject_codes'] || []
    end

    def latitude
      query_parameters['lat']
    end

    def longitude
      query_parameters['lng']
    end

    def google_map_zoom
      '9'
    end

    def degree_grade_types
      degree_required_parameter = query_parameters['degree_required']

      case degree_required_parameter
      when 'two_two'
        'two_two,third_class,not_required'
      when 'third_class'
        'third_class,not_required'
      when 'not_required'
        'not_required'
      end
    end

    def study_type
      return 'full_time,part_time' if fulltime? && parttime?
      return 'full_time' if fulltime?
      return 'part_time' if parttime?
    end

    def qualifications
      query_parameters['qualifications'] || %w[QtsOnly PgdePgceWithQts Other]
    end

    def filtered_subjects
      all_subjects.select { |subject| subject_codes.include?(subject.subject_code) }
    end

    def number_of_subjects_selected
      subject_parameters_array.any? ? subject_parameters_array.length : all_subjects.count
    end

    def course_counter(radius_to_check: nil, include_salary: true)
      course_query = course_query(include_location: radius_to_check.present?, radius_to_query: radius_to_check, include_salary:)
      course_query = course_query.order(:distance) if sort_by_distance?

      course_query.all.meta['count']
    end

    def course_query(include_location:, radius_to_query: radius, include_salary: true)
      base_query = Course
        .includes(site_statuses: [:site])
        .includes(:subjects)
        .includes(:provider)
        .select(
          :name,
          :course_code,
          :provider_code,
          :study_mode,
          :qualification,
          :funding_type,
          :provider_type,
          :level,
          :provider,
          :site_statuses,
          :subjects,
          :recruitment_cycle_year,
          :degree_grade,
          providers: %i[
            provider_name
            address1
            address2
            address3
            address4
            postcode
            can_sponsor_student_visa
            can_sponsor_skilled_worker_visa
          ],
          site_statuses: %i[
            status
            has_vacancies?
            site
          ],
          subjects: %i[
            subject_name
            subject_code
            bursary_amount
            scholarship
          ],
        )

      base_query = base_query.where(recruitment_cycle_year: RecruitmentCycle.current_year)
      base_query = base_query.where(funding: 'salary') if include_salary && with_salaries?
      base_query = base_query.where(has_vacancies: true) if hasvacancies?
      base_query = base_query.where(study_type:) if study_type.present?
      base_query = base_query.where(degree_grade: degree_grade_types) if degree_required?
      base_query = base_query.where(can_sponsor_visa: true) if visa_courses?
      base_query = base_query.where(qualification: qualification.join(',')) unless all_qualifications?
      base_query = base_query.where(subjects: subject_codes.join(',')) if subject_codes.any?
      base_query = base_query.where(send_courses: true) if send_courses?

      if include_location
        base_query = base_query.where('latitude' => latitude)
        base_query = base_query.where('longitude' => longitude)
        base_query = base_query.where('radius' => radius_to_query)
        base_query = base_query.where(expand_university: Settings.expand_university)
      end

      base_query = base_query.where('provider.provider_name' => provider) if provider.present?
      base_query
    end

    def filter_links(links)
      links
        .uniq(&:count)
        .reject { |link| link.count <= course_count }
        .take(MAXIMUM_NUMBER_OF_SUGGESTED_LINKS)
    end

    def radii_for_suggestions
      radius_for_all_england = nil
      [50].reject { |rad| rad <= radius.to_i } << radius_for_all_england
    end

    def suggested_search_link_including_unsalaried(current_radius:)
      suggested_search_link = nil

      radii_including_current = [current_radius] + radii_for_suggestions

      radii_including_current.each do |radius|
        break if suggested_search_link.present?

        count = course_counter(radius_to_check: radius, include_salary: false)

        next unless count > course_count

        suggested_search_link = SuggestedSearchLink.new(
          radius:,
          count:,
          parameters: query_parameters_with_defaults.except('funding'),
          including_non_salaried: true,
        )
      end

      suggested_search_link
    end
  end
end
