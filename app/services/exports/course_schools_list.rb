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
        rows.each do |site, course|
          csv << [
            site.location_name,
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
        .flat_map { |course| placement_sites(course).map { |site| [site, course] } }
        .sort_by { |site, course| [site.location_name.to_s.downcase, course.name.to_s.downcase, course.course_code.to_s] }
    end

    def placement_sites(course)
      course.site_statuses
        .select { |site_status| site_status.status_running? || site_status.status_new_status? }
        .map(&:site)
        .uniq # course_site has no unique index, and duplicate pairs exist
    end

    def courses
      Publish::Courses::Query.call(provider:).preload(site_statuses: :site)
    end
  end
end
