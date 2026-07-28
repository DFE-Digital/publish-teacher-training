module Publish
  module DataExports
    class CourseSchoolsExport < Support::DataExports::Base
      def initialize(courses:) # rubocop:disable Lint/MissingSuper
        @courses = courses

        @include_international_fee_column = courses.any? do |course|
          course.fee? &&
            course.latest_published_enrichment&.fee_international.present?
        end

        @include_study_sites_column = courses.any? do |course|
          course.study_sites.any?
        end
      end

      def data
        rows = []

        @courses.each do |course|
          course.site_statuses.each do |status|
            site = status.site
            next unless site

            row = {
              "Placement schools" => site.location_name || site.code,
              "Course name" => course.name.titleize,
              "Course code" => course.course_code,
              "Age range" => course.age_range_in_years&.humanize,
              "Status" => status(course).titleize,
              # "Fee or salary" => funding_label(course),
              # "Qualification" => qualification(course),
              # "Full time or part time" => course.study_mode.humanize,
              # "Start date" => format_date(course.start_date),
              # "Course length" => course_length(course),
            }

            # row["Placement school postcode"] = site.postcode

            # if @include_study_sites_column
            #   row["Study sites"] = study_sites(course)
            # end

            rows << row
          end
        end

        # sort by course code
        # rows.sort_by! { |row| row["Course code"].to_s.downcase }

        # sort by placement school name
        rows.sort_by! { |row| row["Placement schools"].to_s.downcase }

        rows
      end

    private

      def format_date(date)
        date&.strftime("%B %Y")
      end

      def course_length(course)
        enrichment = course.latest_enrichment || course.latest_published_enrichment
        value = enrichment&.course_length

        return if value.blank?

        case value
        when "OneYear" then "1 year"
        when "TwoYears" then "2 years"
        when "ThreeYears" then "3 years"
        when "FourYears" then "4 years"
        else value
        end
      end

      def qualification(course)
        case course.qualification
        when "qts_with_pgce" then "PGCE with QTS"
        when "qts_only" then "QTS"
        else format_qualification(course.qualification)
        end
      end

      def format_qualification(value)
        value.to_s.humanize
            .gsub(/\bPgce\b/i, "PGCE")
            .gsub(/\bQts\b/i, "QTS")
      end

      def funding_label(course)
        case course.funding
        when "fee"
          "Fee-paying"
        when "salary"
          "Salary"
        when "apprenticeship"
          "Apprenticeship"
        else
          course.funding.to_s.humanize
        end
      end

      def uk_fee(course)
        return unless course.fee?

        format_fee(course.latest_published_enrichment&.fee_uk_eu)
      end

      def international_fee(course)
        return unless course.fee?

        format_fee(course.latest_published_enrichment&.fee_international)
      end

      def format_fee(amount)
        return if amount.blank?

        "£#{amount}"
      end

      def study_sites(course)
        sites = course.study_sites

        return if sites.blank?

        sites.map { |site| site.location_name || site.code }
            .join("\n")
      end

      def status(course)
        if course.is_withdrawn?
          "Withdrawn"
        elsif course.scheduled?
          "Scheduled"
        elsif course.content_status == :draft
          "Draft"
        elsif course.content_status == :rolled_over
          "Rolled over"
        elsif course.open_for_applications?
          "Open"
        elsif course.only_published? && !course.open_for_applications?
          "Closed"
        else
          "Unknown"
        end
      end
    end
  end
end
