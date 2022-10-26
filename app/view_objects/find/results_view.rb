module Find
  # FIND:TODO Will be fleshed out in an upcoming ticket
  class ResultsView
    attr_reader :query_parameters

    include ActionView::Helpers::NumberHelper

    MAXIMUM_NUMBER_OF_SUBJECTS = 43
    DISTANCE = "2".freeze
    SUGGESTED_SEARCH_THRESHOLD = 3
    MAXIMUM_NUMBER_OF_SUGGESTED_LINKS = 2
    RESULTS_PER_PAGE = 10
    MILES = "50".freeze

    def initialize(query_parameters:)
      @query_parameters = query_parameters
    end

    def query_parameters_with_defaults
      query_parameters.except("utf8", "authenticity_token")
        .merge(qualifications_parameters)
        .merge(fulltime_parameters)
        .merge(parttime_parameters)
        .merge(hasvacancies_parameters)
        .merge(sen_courses_parameters)
        .merge(subject_parameters)
    end

    def courses
      @courses ||= RecruitmentCycle.current.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site],
        provider: %i[recruitment_cycle ucas_preferences],
      ).findable.page(query_parameters[:page] || 1)
    end

    def number_of_courses_string
      case course_count
      when 0
        "No courses"
      when 1
        "1 course"
      else
        "#{number_with_delimiter(course_count)} courses"
      end
    end

    def course_count
      courses.count
    end

    def subjects
      subject_codes.any? ? filtered_subjects : all_subjects
    end

    def qualifications_parameters
      { "qualifications" => query_parameters["qualifications"].presence || %w[QtsOnly PgdePgceWithQts Other] }
    end

    def fulltime_parameters
      { "fulltime" => fulltime? }
    end

    def parttime_parameters
      { "parttime" => parttime? }
    end

    def hasvacancies_parameters
      { "hasvacancies" => hasvacancies? }
    end

    def sen_courses_parameters
      { "senCourses" => sen_courses? }
    end

    def fulltime?
      return false if query_parameters["fulltime"].nil?

      query_parameters["fulltime"] == "true"
    end

    def parttime?
      return false if query_parameters["parttime"].nil?

      query_parameters["parttime"] == "true"
    end

    def hasvacancies?
      return true if query_parameters["hasvacancies"].nil?

      query_parameters["hasvacancies"] == "true"
    end

    def sen_courses?
      query_parameters["senCourses"] == "true"
    end

    # FIND:TODO double check
    def subject_parameters
      query_parameters["subject_codes"].present? ? { "subject_codes" => query_parameters["subject_codes"].presence } : {}
    end

    def subject_codes
      query_parameters["subject_codes"] || []
    end

    def all_subjects
      @all_subjects ||= Subject.select(:subject_name, :subject_code).order(:subject_name).all
    end

    def filtered_subjects
      all_subjects.select { |subject| subject_codes.include?(subject.subject_code) }
    end

    def provider
      query_parameters["query"]
    end

    def location_filter?
      query_parameters["l"] == "1"
    end

    def england_filter?
      query_parameters["l"] == "2"
    end

    def provider_filter?
      query_parameters["l"] == "3"
    end

    def location_search
      query_parameters["lq"]
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
      query_parameters["c"]
    end

    def no_results_found?
      course_count.zero?
    end

    def has_results?
      course_count.positive?
    end

    def with_salaries?
      query_parameters["funding"] == "8"
    end

    def sort_options
      [
        ["Training provider (A-Z)", 0, { "data-qa": "sort-form__options__ascending" }],
        ["Training provider (Z-A)", 1, { "data-qa": "sort-form__options__descending" }],
      ]
    end

    def suggested_search_visible?
      course_count < SUGGESTED_SEARCH_THRESHOLD && suggested_search_links.any? && !devolved_nation?
    end

    def has_sites?(course)
      !new_or_running_sites_with_vacancies_for(course).empty?
    end

    def total_pages
      (course_count.to_f / results_per_page).ceil
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

  private

    def results_per_page
      RESULTS_PER_PAGE
    end

    def stripped_devolved_nation_params(path)
      parameters = query_parameters_with_defaults.except("c", "lat", "long", "loc", "lq", "l")
      filter_params_with_unescaped_commas(path, parameters:)
    end

    def filter_params_with_unescaped_commas(base_path, parameters: query_parameters_with_defaults)
      Find::UnescapedQueryStringService.call(base_path:, parameters:)
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
          parameters: query_parameters_with_defaults.except("funding"),
          including_non_salaried: true,
        )
      end

      suggested_search_link
    end
  end
end
