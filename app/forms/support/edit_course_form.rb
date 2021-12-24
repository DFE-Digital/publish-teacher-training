module Support
  class EditCourseForm
    include ActiveModel::Model
    include ActiveModel::Validations

    FIELDS = %i[
      course_code name
    ].freeze

    attr_accessor(*FIELDS)
    attr_accessor :start_date_day, :start_date_month, :start_date_year, :course
    validate :validate_start_date_format

    def initialize(course)
      @course = course

      super(
        course_code: @course.course_code,
        name: @course.name,
        start_date_day: @course.start_date&.day,
        start_date_month: @course.start_date&.month,
        start_date_year: @course.start_date&.year,
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
      @start_date ||= check_start_date
    end

  private

    def check_start_date
      date_args = [start_date_year, start_date_month, start_date_day].map(&:to_i)

      Date.valid_date?(*date_args) ? Date.new(*date_args) : Struct.new(:day, :month, :year).new(start_date_day, start_date_month, start_date_year)
    end

    def assign_attributes_to_course
      attributes = {
        course_code: course_code,
        name: name,
      }

      attributes[:start_date] = start_date if valid_date? || date_args_blank?

      course.assign_attributes(attributes)
    end

    def promote_errors_from_course
      errors.merge!(course.errors)
    end

    def validate_start_date_format
      return if date_args_blank?

      errors.add(:start_date, "Start date format is invalid") unless valid_date?
    end

    def valid_date?
      start_date.is_a?(Date)
    end

    def date_args_blank?
      [start_date_year, start_date_month, start_date_day].any?(&:blank?)
    end
  end
end
