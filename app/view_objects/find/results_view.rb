# frozen_string_literal: true

module Find
  # FIND:TODO need to prune unused methods etc.
  class ResultsView
    attr_reader :query_parameters, :course_type_answer_determiner

    include ActionView::Helpers::NumberHelper

    DISTANCE = 'distance'
    MILES = '10'

    delegate :show_undergraduate_courses?, to: :course_type_answer_determiner

    def initialize(query_parameters:)
      @query_parameters = query_parameters
      @course_type_answer_determiner = CourseTypeAnswerDeterminer.new(
        university_degree_status: query_parameters['university_degree_status'],
        age_group: query_parameters['age_group'],
        visa_status: query_parameters['visa_status']
      )
    end

    def query_parameters_with_defaults
      query_parameters.except('utf8', 'authenticity_token')
                      .merge(qualifications_parameters)
                      .merge(study_type_parameters)
                      .merge(has_vacancies_parameters)
                      .merge(sen_courses_parameters)
                      .merge(subject_parameters)
    end

    def courses
      @courses ||= ::CourseSearchService.call(
        filter: filter_parameters,
        sort: query_parameters[:sortby] || 'course_asc',
        course_scope:
      )
    end

    def filter_parameters
      query_parameters['qualification'] = Course.qualifications.keys.grep(/undergraduate/) if show_undergraduate_courses?
      query_parameters
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

    def course_count
      courses.count(:all)
    end

    def subjects
      subject_codes.any? ? filtered_subjects : all_subjects
    end

    def qualifications_parameters
      { 'qualification' => query_parameters['qualification'].presence || ['qts', 'pgce_with_qts', 'pgce pgde'] }
    end

    def study_type_parameters
      { 'study_type' => query_parameters['study_type'].presence || %w[full_time part_time] }
    end

    def has_vacancies_parameters
      { 'has_vacancies' => has_vacancies? }
    end

    def sen_courses_parameters
      { 'send_courses' => sen_courses? }
    end

    def has_vacancies?
      return true if query_parameters['has_vacancies'].nil?

      query_parameters['has_vacancies'] == 'true'
    end

    def sen_courses?
      query_parameters['send_courses'] == 'true'
    end

    # FIND:TODO double check
    def subject_parameters
      query_parameters['subjects'].present? ? { 'subjects' => query_parameters['subjects'].presence } : {}
    end

    def subject_codes
      query_parameters['subjects'] || []
    end

    def filtered_subjects
      all_subjects.select { |subject| subject_codes.include?(subject.subject_code) }
    end

    def provider
      query_parameters['provider.provider_name']
    end

    def location
      query_parameters['loc'] || 'Across England'
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

    def filter_params_for(path)
      if devolved_nation?
        stripped_devolved_nation_params(path)
      else
        filter_params_with_unescaped_commas(path)
      end
    end

    def devolved_nation?
      DEVOLVED_NATIONS.include?(country)
    end

    def country
      query_parameters['c']
    end

    def no_results_found?
      course_count.zero?
    end

    def has_results?
      course_count.positive?
    end

    def sort_options
      [
        ['Course name (A-Z)', 'course_asc', { 'data-qa': 'sort-form__options__ascending_course' }],
        ['Course name (Z-A)', 'course_desc', { 'data-qa': 'sort-form__options__descending_course' }],
        ['Training provider (A-Z)', 'provider_asc', { 'data-qa': 'sort-form__options__ascending_provider' }],
        ['Training provider (Z-A)', 'provider_desc', { 'data-qa': 'sort-form__options__descending_provider' }]
      ]
    end

    def sites_count(course)
      new_or_running_sites_with_vacancies_for(course).count
    end

    def nearest_address(course)
      nearest_address = nearest_location(course)

      [
        nearest_address.address1,
        nearest_address.address2,
        nearest_address.address3,
        nearest_address.town,
        nearest_address.address4,
        nearest_address.postcode
      ].select(&:present?).join(', ').html_safe
    end

    def nearest_location_name(course)
      nearest_location(course).location_name
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

    def with_salaries?
      query_parameters['funding'] == 'salary'
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

    def filter_params_with_unescaped_commas(base_path, parameters: query_parameters_with_defaults)
      Find::UnescapedQueryStringService.call(base_path:, parameters:)
    end

    def all_subjects
      @all_subjects ||= Subject.select(:subject_name, :subject_code).order(:subject_name).all
    end

    private

    def latitude
      query_parameters['latitude']
    end

    def longitude
      query_parameters['longitude']
    end

    def lat_long
      Geokit::LatLng.new(latitude.to_f, longitude.to_f)
    end

    def nearest_location(course)
      new_or_running_sites_with_vacancies_for(course).min_by do |site|
        lat_long.distance_to("#{site.latitude},#{site.longitude}")
      end
    end

    def stripped_devolved_nation_params(path)
      parameters = query_parameters_with_defaults.except('c', 'latitude', 'long', 'loc', 'lq', 'l')
      filter_params_with_unescaped_commas(path, parameters:)
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
        [site.address1, site.address2, site.address3, site.town, site.address4, site.postcode].all?(&:blank?)
      end

      sites.reject do |site|
        site.latitude.blank? || site.longitude.blank?
      end
    end

    def course_scope
      @course_scope ||= RecruitmentCycle.current.courses.findable
    end
  end
end
