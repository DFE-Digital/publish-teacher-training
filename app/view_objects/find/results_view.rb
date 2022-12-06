module Find
  # FIND:TODO need to prune unused methods etc.
  class ResultsView
    attr_reader :query_parameters

    include ActionView::Helpers::NumberHelper

    MAXIMUM_NUMBER_OF_SUBJECTS = 43
    DISTANCE = "distance".freeze
    # SUGGESTED_SEARCH_THRESHOLD = 3
    MAXIMUM_NUMBER_OF_SUGGESTED_LINKS = 2
    # RESULTS_PER_PAGE = 10
    MILES = "50".freeze

    def initialize(query_parameters:)
      @query_parameters = query_parameters
    end

    def query_parameters_with_defaults
      query_parameters.except("utf8", "authenticity_token")
        .merge(qualifications_parameters)
        .merge(study_type_parameters)
        .merge(has_vacancies_parameters)
        .merge(sen_courses_parameters)
        .merge(subject_parameters)
    end

    def courses
      @courses ||= ::CourseSearchService.call(
        filter: query_parameters,
        sort: query_parameters[:sortby] || "0",
        course_scope:,
      )
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
      courses.count(:all)
    end

    # def subjects
    #  subject_codes.any? ? filtered_subjects : all_subjects
    # end

    def qualifications_parameters
      { "qualification" => query_parameters["qualification"].presence || ["qts", "pgce_with_qts", "pgce pgde"] }
    end

    def study_type_parameters
      { "study_type" => query_parameters["study_type"].presence || %w[full_time part_time] }
    end

    def has_vacancies_parameters
      { "has_vacancies" => has_vacancies? }
    end

    def sen_courses_parameters
      { "send_courses" => sen_courses? }
    end

    def has_vacancies?
      return true if query_parameters["has_vacancies"].nil?

      query_parameters["has_vacancies"] == "true"
    end

    def sen_courses?
      query_parameters["send_courses"] == "true"
    end

    # FIND:TODO double check
    def subject_parameters
      query_parameters["subjects"].present? ? { "subjects" => query_parameters["subjects"].presence } : {}
    end

    def subject_codes
      query_parameters["subjects"] || []
    end

    def filtered_subjects
      all_subjects.select { |subject| subject_codes.include?(subject.subject_code) }
    end

    def provider
      query_parameters["provider.provider_name"]
    end

    def location
      query_parameters["loc"] || "Across England"
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

    def sites_count(course)
      new_or_running_sites_with_vacancies_for(course).count
    end

    def nearest_address(course)
      nearest_address = nearest_location(course)

      [
        nearest_address.address1,
        nearest_address.address2,
        nearest_address.address3,
        nearest_address.address4,
        nearest_address.postcode,
      ].select(&:present?).join(", ").html_safe
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

    def radius
      MILES
    end

    def degree_required?
      query_parameters["degree_required"].present? && query_parameters["degree_required"] != "show_all_courses"
    end

    def visa_courses?
      query_parameters["can_sponsor_visa"].present? && query_parameters["can_sponsor_visa"].downcase == "true"
    end

    def engineers_teach_physics_courses?
      query_parameters["engineers_teach_physics"].present? && query_parameters["engineers_teach_physics"].downcase == "true"
    end

    def with_salaries?
      query_parameters["funding"] == "8"
    end

    def send_courses?
      query_parameters["send_courses"].present? && query_parameters["send_courses"].downcase == "true"
    end

    def sort_by_distance?
      sort_by == DISTANCE
    end

    def sort_by
      query_parameters["sortby"]
    end

    def placement_schools_summary(course)
      site_distance = site_distance(course)

      if site_distance < 11
        "Placement schools are near you"
      elsif site_distance < 21
        "Placement schools might be near you"
      else
        "Placement schools might be in commuting distance"
      end
    end

    def filter_params_with_unescaped_commas(base_path, parameters: query_parameters_with_defaults)
      Find::UnescapedQueryStringService.call(base_path:, parameters:)
    end

    def number_of_extra_subjects
      return 37 if number_of_subjects_selected == MAXIMUM_NUMBER_OF_SUBJECTS

      number_of_subjects_selected
    end

    def all_subjects
      @all_subjects ||= Subject.select(:subject_name, :subject_code).order(:subject_name).all
    end

    def show_map?
      latitude.present? && longitude.present?
    end

  private

    def number_of_subjects_selected
      subject_parameters_array.any? ? subject_parameters_array.length : all_subjects.count(:all)
    end

    def subject_parameters_array
      query_parameters["subjects"] || []
    end

    def filter_links(links)
      links
        .uniq(&:count)
        .reject { |link| link.count <= course_count }
        .take(MAXIMUM_NUMBER_OF_SUGGESTED_LINKS)
    end

    def course_counter(radius_to_check: nil, include_salary: true)
      course_query = course_query(include_location: radius_to_check.present?, radius_to_query: radius_to_check, include_salary:)
      course_query = course_query.order(:distance) if sort_by_distance?

      course_query.count(:all)
    end

    def radii_for_suggestions
      radius_for_all_england = nil
      [50].reject { |radius| radius <= radius.to_i } << radius_for_all_england
    end

    def study_type
      return "full_time,part_time" if fulltime? && parttime?
      return "full_time" if fulltime?
      return "part_time" if parttime?
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
          :can_sponsor_student_visa,
          :can_sponsor_skilled_worker_visa,
          providers: %i[
            provider_name
            address1
            address2
            address3
            address4
            postcode
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

      base_query = base_query.with_recruitment_cycle(RecruitmentCycle.current.year)
      base_query = base_query.where(funding: "salary") if include_salary && with_salaries?
      base_query = base_query.with_vacancies if hasvacancies?
      base_query = base_query.where(study_type:) if study_type.present?
      base_query = base_query.where(degree_grade: degree_grade_types) if degree_required?
      base_query = base_query.where(can_sponsor_visa: true) if visa_courses?
      base_query = base_query.where(engineers_teach_physics: true) if engineers_teach_physics_courses?
      base_query = base_query.where(qualification: qualification.join(",")) unless all_qualifications?
      base_query = base_query.joins(:subjects).merge(Subject.with_subject_codes(subject_codes)) if subject_codes.any?
      base_query = base_query.where(send_courses: true) if send_courses?

      if include_location
        base_query = base_query.where("latitude" => latitude)
        base_query = base_query.where("longitude" => longitude)
        base_query = base_query.where("radius" => radius_to_query)
        base_query = base_query.where(expand_university: Settings.expand_university)
      end

      base_query = base_query.where("provider.provider_name" => provider) if provider.present?
      base_query
    end

    def latitude
      query_parameters["latitude"]
    end

    def longitude
      query_parameters["longitude"]
    end

    def lat_long
      Geokit::LatLng.new(latitude.to_f, longitude.to_f)
    end

    def results_per_page
      RESULTS_PER_PAGE
    end

    def nearest_location(course)
      new_or_running_sites_with_vacancies_for(course).min_by do |site|
        lat_long.distance_to("#{site.latitude},#{site.longitude}")
      end
    end

    def stripped_devolved_nation_params(path)
      parameters = query_parameters_with_defaults.except("c", "latitude", "long", "loc", "lq", "l")
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

    def sort_by_provider
      order = {
        "0" => :PROVIDER_ASCENDING,
        "1" => :PROVIDER_DESCENDING,
      }
      order[query_parameters&.dig(:sortby)]
    end

    def sort
      ::CourseSearchService.const_get("::CourseSearchService::#{sort_by_provider}").join(",")
    end

    def course_scope
      @course_scope ||= RecruitmentCycle.current.courses.findable
    end
  end
end
