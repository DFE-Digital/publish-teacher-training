module Support
  class EditCourseForm
    include ActiveModel::Model
    include ActiveModel::Validations

    FIELDS = %i[
      course_code name
    ].freeze

    attr_accessor(*FIELDS)
    attr_accessor :start_date_day, :start_date_month, :start_date_year, :course, :applications_open_from_day, :applications_open_from_month, :applications_open_from_year
    validate :validate_start_date_format
    validate :validate_applications_open_from_format

    def initialize(course)
      @course = course

      super(
        course_code: @course.course_code,
        name: @course.name,
        start_date_day: @course.start_date&.day,
        start_date_month: @course.start_date&.month,
        start_date_year: @course.start_date&.year,
        applications_open_from_day: @course.applications_open_from&.day,
        applications_open_from_month: @course.applications_open_from&.month,
        applications_open_from_year: @course.applications_open_from&.year,
      )
    end

    def save
      return false unless valid?

      @course.save
    end

    def valid?
      super()
      assign_attributes_to_course
      course.valid?
      promote_errors_from_course
      errors.none?
    end

    def start_date
      @start_date ||= check_date(:start_date)
    end

    def applications_open_from
      @applications_open_from ||= check_date(:applications_open_from)
    end

  private

    def check_date(date_type)
      date_args = date_array(date_type).map(&:to_i)

      return Date.new(*date_args) if Date.valid_date?(*date_args)

      date_struct(date_type)
    end

    def date_struct(date_type)
      Struct.new(:day, :month, :year).new(
        send("#{date_type}_day"),
        send("#{date_type}_month"),
        send("#{date_type}_year"),
      )
    end

    def date_array(date_type)
      [send("#{date_type}_year"), send("#{date_type}_month"), send("#{date_type}_day")]
    end

    def assign_attributes_to_course
      attributes = {
        course_code: course_code,
        name: name,
        start_date: start_date,
        applications_open_from: applications_open_from,
      }

      course.assign_attributes(attributes)
    end

    def promote_errors_from_course
      errors.merge!(course.errors)
    end

    def validate_start_date_format
      validate_date(:start_date)
    end

    def validate_applications_open_from_format
      validate_date(:applications_open_from)
    end

    def validate_date(date_type)
      return if date_args_blank?(date_type)

      errors.add(date_type, "#{attribute(date_type)} format is invalid") unless valid_date?(date_type)
    end

    def attribute(date_type)
      case date_type
      when :applications_open_from
        "#{date_type.to_s.humanize.capitalize} date"
      else
        date_type.to_s.humanize.capitalize
      end
    end

    def valid_date?(date_type)
      send(date_type).is_a?(Date)
    end

    def date_args_blank?(date_type)
      date_array(date_type).any?(&:blank?)
    end
  end
end
