module Publish
  module DataExports
    class CourseInformationExport < Support::DataExports::Base
      def initialize(courses:, provider:, params: {}) # rubocop:disable Lint/MissingSuper
        @courses = courses
        @provider = provider
        @params = params

        # only include these columns if the information differs between courses
        @include_funding_column =
          courses.map(&:funding).compact.uniq.many?

        @include_qualification_column =
          courses.map { |course| qualification(course) }.compact.uniq.many?

        @include_study_mode_column =
          courses.map(&:study_mode).compact.uniq.many?

        @include_start_date_column =
          courses.map(&:start_date).compact.uniq.many?

        @include_course_length_column =
          courses.map { |course| course_length(course) }.compact.uniq.many?

        # only include these columns if one or more courses have this data
        @include_international_fee_column = courses.any? do |course|
          course.fee? &&
            course.latest_published_enrichment&.fee_international.present?
        end

        @include_visa_deadline_column = courses.any? do |course|
          course.visa_sponsorship_application_deadline_at.present?
        end
      end

      def data
        @courses.map do |course|
          row = {
            "Course name" => course.name.titleize,
            "Course code" => course.course_code,
            "Status" => status(course).titleize,
            "Age range" => course.age_range_in_years&.humanize,
          }

          row["Funding"] = course.funding.titleize if @include_funding_column

          row["Qualification"] = qualification(course) if @include_qualification_column

          row["Study mode"] = course.study_mode.titleize if @include_study_mode_column

          row["Start date"] = format_date(course.start_date) if @include_start_date_column

          row["Course length"] = course_length(course) if @include_course_length_column

          row["UK fee"] = uk_fee(course)

          # row["Entry requirements"] = entry_requirements(course)

          if @include_international_fee_column
            row["International fee"] = international_fee(course)
          end

          if @include_visa_deadline_column
            row["Visa sponsorship deadline"] = visa_sponsorship_deadline(course)
          end

          row
        end
      end

    private

      def placement_schools(course)
        course.site_statuses
              .filter_map { |status| status.site&.location_name }
              .join(", ")
      end

      def format_date(date)
        date&.strftime("%B %Y")
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

      def entry_requirements(course)
        course.required_qualifications
      end

      def study_sites(course)
        sites = course.study_sites

        return if sites.blank?

        sites.map { |site| site.location_name || site.code }
            .join("\n")
      end

      def visa_sponsorship_deadline(course)
        course.visa_sponsorship_application_deadline_at&.strftime("%d/%m/%Y")
      end
    end
  end
end
