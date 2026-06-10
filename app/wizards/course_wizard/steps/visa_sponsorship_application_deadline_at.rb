# frozen_string_literal: true

class CourseWizard
  module Steps
    class VisaSponsorshipApplicationDeadlineAt
      include DfE::Wizard::Step

      DateParts = Struct.new(:year, :month, :day)

      attribute :visa_sponsorship_application_deadline_at

      validate :date_present
      validate :within_range

      # rubocop:disable Naming/MethodName
      define_method("visa_sponsorship_application_deadline_at(1i)=") do |value|
        @deadline_year = value
        compose_deadline_parts
      end

      define_method("visa_sponsorship_application_deadline_at(2i)=") do |value|
        @deadline_month = value
        compose_deadline_parts
      end

      define_method("visa_sponsorship_application_deadline_at(3i)=") do |value|
        @deadline_day = value
        compose_deadline_parts
      end
      # rubocop:enable Naming/MethodName

      def self.permitted_params
        %i[
          visa_sponsorship_application_deadline_at
          visa_sponsorship_application_deadline_at(1i)
          visa_sponsorship_application_deadline_at(2i)
          visa_sponsorship_application_deadline_at(3i)
        ]
      end

    private

      def date_present
        error_type = if [year, month, day].all?(&:blank?)
                       :all_blank
                     elsif [year, month, day].any?(&:blank?)
                       :some_blank
                     elsif [year, month, day].any? { |entry| entry.match?(/\A[a-zA-Z'-]*\z/) }
                       :not_integers
                     end

        errors.add(:visa_sponsorship_application_deadline_at, error_type) if error_type.present?
      end

      def within_range
        set_date

        unless @date.between?(first_valid_datetime, last_valid_datetime)
          errors.add(
            :visa_sponsorship_application_deadline_at,
            :not_in_range,
            earliest_date: formatted_first_valid_datetime,
            apply_deadline: last_valid_datetime.to_fs(:govuk_date_and_time),
          )
        end
      rescue Date::Error
        errors.add(:visa_sponsorship_application_deadline_at, :invalid_date)
      end

      def set_date
        # We use DateTime here instead of Time.zone because DateTime is better at
        # validating dates.
        # Time.zone.local(2026, 2, 31) # => => 2026-03-03 00:00:00.000000000 GMT +00:00
        # DateTime.new(2026, 2, 31) # => Date::Error: invalid date (Date::Error)
        @date = DateTime.new(year.to_i, month.to_i, day.to_i) # rubocop:disable Style/DateTime
          .in_time_zone
          .end_of_day
      end

      def year
        visa_sponsorship_application_deadline_at&.year
      end

      def month
        visa_sponsorship_application_deadline_at&.month
      end

      def day
        visa_sponsorship_application_deadline_at&.day
      end

      def last_valid_datetime
        @last_valid_datetime ||= Find::CycleTimetable.date(:apply_deadline, wizard.recruitment_cycle.year.to_i)
      end

      def first_valid_datetime
        [Time.zone.now, start_of_cycle].max
      end

      def formatted_first_valid_datetime
        if Time.zone.now.after? start_of_cycle
          "today"
        else
          start_of_cycle.to_fs(:govuk_date_and_time)
        end
      end

      def start_of_cycle
        @start_of_cycle ||= wizard.recruitment_cycle.application_start_date.end_of_day.change(hour: 9)
      end

      def compose_deadline_parts
        self.visa_sponsorship_application_deadline_at = DateParts.new(
          @deadline_year,
          @deadline_month,
          @deadline_day,
        )
      end
    end
  end
end
