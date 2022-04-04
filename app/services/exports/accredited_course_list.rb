# frozen_string_literal: true

require "csv"

module Exports
  class AccreditedCourseList
    def initialize(courses)
      @data_for_export = format_courses(courses)
    end

    def data
      CSV.generate(headers: data_for_export.first.keys, write_headers: true) do |csv|
        data_for_export.each do |course_csv_row|
          csv << course_csv_row
        end
      end
    end

    def filename
      "courses-#{Time.zone.today}.csv"
    end

  private

    attr_reader :data_for_export

    def format_courses(courses)
      courses
      .map(&:decorate)
      .flat_map do |c|
        base_data = {
          "Provider code" => c.provider.provider_code,
          "Provider" => c.provider.provider_name,
          "Course code" => c.course_code,
          "Course" => c.name,
          "Study mode" => c.study_mode&.humanize,
          "Programme type" => c.program_type&.humanize,
          "Qualification" => c.outcome,
          "Status" => c.content_status&.to_s&.humanize,
          "View on Find" => c.find_url,
          "Applications open from" => I18n.l(c.applications_open_from&.to_date),
          "Vacancies" => c.has_vacancies? ? "Yes" : "No",
        }
        if c.sites
          base_data.merge({ "Campus Codes" => c.sites.pluck(:code).join(" ") })
        else
          base_data
        end
      end
    end
  end
end
