module Support
  class EditCourseForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :course_code, :name, :day, :month, :year
    validate :validate_start_date_format

    def initialize(course)
      @course = course

      super(
        course_code: @course.course_code,
        name: @course.name,
        day: @course.start_date&.day,
        month: @course.start_date&.month,
        year: @course.start_date&.year,
      )
    end

    def save
      # not ideal but whilst validation is in 2 places this should prevent overlap
      # this can be removed when we migrate validation over
      if valid_date? || date_args_blank?
        @course.update(
          course_code: course_code,
          name: name,
          start_date: start_date,
        )
      else
        @course.update(
          course_code: course_code,
          name: name,
        )
      end
    end

    def course_valid?
      @course.valid?

      promote_errors
    end

    def start_date
      @start_date ||= check_start_date
    end

  private

    def check_start_date
      date_args = [year, month, day].map(&:to_i)

      begin
        Date.new(*date_args)
      rescue ArgumentError
        Struct.new(:day, :month, :year).new(day, month, year)
      end
    end

    def promote_errors
      @course.errors.each do |error|
        errors.add(error.attribute, error.message)
      end
    end

    def validate_start_date_format
      return if date_args_blank?

      errors.add(:start_date, "Start date format is invalid") unless valid_date?
    end

    def valid_date?
      start_date.is_a?(Date)
    end

    def date_args_blank?
      [year, month, day].any?(&:blank?)
    end
  end
end
