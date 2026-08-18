# frozen_string_literal: true

require "csv"

module Exports
  class CourseSchoolsList
    include CourseColumns

    CSV_HEADERS = [
      "Placement schools",
      "Course name",
      "Course code",
      "Status",
      "Age range",
    ].freeze

    def initialize(provider:)
      @provider = provider
    end

    def data
      CSV.generate(headers: CSV_HEADERS, write_headers: true) do |csv|
        rows.each do |school_name, course|
          csv << [
            school_name,
            course.name,
            course.course_code,
            status(course),
            age_range(course),
          ]
        end
      end
    end

    def filename
      "schools-attached-to-courses-#{provider.provider_code}-#{Time.zone.today}.csv"
    end

  private

    attr_reader :provider

    def rows
      courses
        .flat_map { |course| placement_schools(course).map { |name| [name, course] } }
        .sort_by { |name, course| [name.downcase, course.name.to_s.downcase, course.course_code.to_s] }
    end

    def placement_schools(course)
      course.schools.filter_map(&:gias_school).uniq(&:id).map(&:name)
    end

    def courses
      Publish::Courses::Query.call(provider:).preload(schools: :gias_school)
    end
  end
end
