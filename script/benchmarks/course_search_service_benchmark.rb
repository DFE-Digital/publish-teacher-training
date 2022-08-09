# frozen_string_literal: true

require_relative "../../config/environment"

search_args = {
  filter_with_nil: { filter: nil },
  filter_with_blank: { filter: {} },
  sort_ascending: { filter: {}, sort: "name,provider.provider_name" },
  sort_descending: { filter: {}, sort: "-name,-provider.provider_name" },
  sort_by_distance_without_expand_university: { filter: { latitude: 54.9713392, longitude: -1.6112336, expand_university: "false" }, sort: "distance" },
  sort_by_distance_with_missing_expand_university: { filter: { latitude: 54.9713392, longitude: -1.6112336 }, sort: "distance" },
  sort_by_distance_with_expand_university: { filter: { latitude: 54.9713392, longitude: -1.6112336, expand_university: "true" }, sort: "distance" },
  sort_by_range: { filter: { longitude: 0, latitude: 1, radius: 5 } },
  filter_with_provider_name: { filter: { "provider.provider_name": "University of Warwick" } },
  filter_with_updated_since: { filter: { updated_since: Time.zone.now.iso8601 } },
  filter_with_funding_type_salary: { filter: { funding: "salary" } },
  filter_with_funding_type_all: { filter: { funding: "fee,salary,apprenticeship" } },
  filter_with_funding_type_fee: { filter: { funding: "fee" } },
  filter_with_funding_type_apprenticeship: { filter: { funding: "apprenticeship" } },
  filter_with_qualification: { filter: { qualification: "pgde,pgce_with_qts,pgde_with_qts,qts,pgce" } },
  filter_with_vacancies: { filter: { has_vacancies: true } },
  filter_with_no_vacancies: { filter: { has_vacancies: false } },
  filter_with_findable: { filter: { findable: true } },
  filter_with_no_findable: { filter: { findable: false } },
  filter_with_full_time: { filter: { study_type: "full_time" } },
  filter_with_part_time: { filter: { study_type: "part_time" } },
  filter_with_part_time_and_full_time: { filter: { study_type: "part_time,full_time" } },
  filter_with_degree_type_two_two: { filter: { degree_grade: "two_two" } },
  filter_with_degree_type_third_class: { filter: { degree_grade: "third_class" } },
  filter_with_degree_type_not_required: { filter: { degree_grade: "not_required" } },
  filter_with_degree_type_all: { filter: { degree_grade: "two_one,two_two,third_class,not_required" } },
  filter_with_single_subject: { filter: { subjects: "A1" } },
  filter_with_mulitple_subject: { filter: { subjects: "A1,B2" } },
  filter_with_send_courses: { filter: { send_courses: true } },
  filter_with_no_send_courses: { filter: { send_courses: false } },
  filter_with_can_sponsor_visa: { filter: { can_sponsor_visa: true } },
  filter_with_no_can_sponsor_visa: { filter: { can_sponsor_visa: false } },
}

search_args.each do |key, args|
  Benchmark.ips do |x|
    x.report("before #{key}") do
      CourseSearchService.call(**args)
    end

    x.report("After 1 #{key}") do
      CourseSearchResultsService.call(**args)
    end

    x.report("After 2 #{key}") do
      ImprovedCourseSearchService.call(**args)
    end

    x.compare!
  end
end

Benchmark.ips do |x|
  search_args.each do |key, args|
    x.report("before") do
      CourseSearchService.call(**args)
    end

    x.report("After 1") do
      CourseSearchResultsService.call(**args)
    end

    x.report("After 2") do
      ImprovedCourseSearchService.call(**args)
    end

    x.compare!
  end
end
