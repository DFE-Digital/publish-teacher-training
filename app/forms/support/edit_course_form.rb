# frozen_string_literal: true

module Support
  class EditCourseForm
    include ActiveModel::Model
    include ActiveModel::Validations

    FIELDS = %i[
      course_code name
    ].freeze

    attr_accessor(*FIELDS, :start_date_day, :start_date_month, :start_date_year, :course, :is_send, :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa, :accredited_provider_code, :publish_without_schools_allowed)

    validate :validate_start_date_format

    def initialize(course)
      @course = course

      super(
        course_code: @course.course_code,
        name: @course.name,
        start_date_day: @course.start_date&.day,
        start_date_month: @course.start_date&.month,
        start_date_year: @course.start_date&.year,
        is_send: @course.is_send,
        can_sponsor_student_visa: @course.can_sponsor_student_visa,
        can_sponsor_skilled_worker_visa: @course.can_sponsor_skilled_worker_visa,
        accredited_provider_code: @course.accredited_provider_code,
        publish_without_schools_allowed: @course.publish_without_schools_allowed
      )
    end

    def save
      return false unless valid?

      @course.save
    end

    def valid?
      super
      assign_attributes_to_course
      assign_default_applications_open_from
      course.valid?
      promote_errors_from_course
      errors.none?
    end

    def start_date
      @start_date ||= check_date(:start_date)
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
        course_code:,
        name:,
        start_date: valid_date?(:start_date) ? start_date : nil,
        is_send: send?,
        can_sponsor_student_visa:,
        can_sponsor_skilled_worker_visa:,
        accredited_provider_code:,
        publish_without_schools_allowed: publish_without_schools_allowed?,
      }

      course.assign_attributes(attributes)
    end

    # A blank date is filled from the cycle on save. Do that before validation,
    # because this page no longer has a field for it.
    def assign_default_applications_open_from
      course.applications_open_from ||= course.recruitment_cycle.application_start_date
    end

    def promote_errors_from_course
      errors.merge!(course.errors)
    end

    def send?
      ActiveModel::Type::Boolean.new.cast(is_send)
    end

    def publish_without_schools_allowed?
      ActiveModel::Type::Boolean.new.cast(publish_without_schools_allowed)
    end

    def validate_start_date_format
      validate_date(:start_date)
    end

    def validate_date(date_type)
      return if date_args_blank?(date_type)

      errors.add(date_type, "#{attribute(date_type)} format is invalid") unless valid_date?(date_type)
    end

    def attribute(date_type)
      date_type.to_s.humanize.capitalize
    end

    def valid_date?(date_type)
      send(date_type).is_a?(Date)
    end

    def date_args_blank?(date_type)
      date_array(date_type).any?(&:blank?)
    end
  end
end
