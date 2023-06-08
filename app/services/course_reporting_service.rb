# frozen_string_literal: true

class CourseReportingService
  def initialize(courses_scope: Course)
    @courses = courses_scope.distinct
    @findable_courses = @courses.findable
    @open_courses = @findable_courses.application_status_open
    @closed_courses = @findable_courses.application_status_closed
  end

  class << self
    def call(courses_scope:)
      new(courses_scope:).call
    end
  end

  def call
    {
      total: {
        all: @courses.count,
        non_findable: @courses.count - @findable_courses.count,
        all_findable: @findable_courses.count
      },
      findable_total: {
        open: @open_courses.count,
        closed: @closed_courses.count
      },
      provider_type: { **group_by_count(:provider_type) },
      program_type: { **group_by_count(:program_type) },

      study_mode: { **group_by_count(:study_mode) },
      qualification: { **group_by_count(:qualification) },
      is_send: { **group_by_count(:is_send) },

      subject: { **group_by_subject_count }
    }
  end

  private_class_method :new

  private

  def group_by_subject_count
    open = CourseSubject.where(course_id: @open_courses).group(:subject_id).count
    closed = CourseSubject.where(course_id: @closed_courses).group(:subject_id).count

    {
      open: Subject.active.map do |sub|
              x = {}
              x[sub.subject_name] = open[sub.id] || 0
              x
            end.reduce({}, :merge),
      closed: Subject.active.map do |sub|
                x = {}
                x[sub.subject_name] = closed[sub.id] || 0
                x
              end.reduce({}, :merge)
    }
  end

  def group_by_count(column)
    open = @open_courses.group(column).count
    closed = @closed_courses.group(column).count

    case column
    when :provider_type
      {
        open: Provider.provider_types.map do |key, value|
                x = {}
                x[key.to_sym] = open[value] || 0
                x
              end.reduce({}, :merge),
        closed: Provider.provider_types.map do |key, value|
                  x = {}
                  x[key.to_sym] = closed[value] || 0
                  x
                end.reduce({}, :merge)
      }
    when :program_type, :study_mode, :qualification
      {
        open: Course.send(column.to_s.pluralize).map do |key, _value|
                x = {}
                x[key.to_sym] = open[key] || 0
                x
              end.reduce({}, :merge),
        closed: Course.send(column.to_s.pluralize).map do |key, _value|
                  x = {}
                  x[key.to_sym] = closed[key] || 0
                  x
                end.reduce({}, :merge)
      }
    when :is_send
      {
        open: { yes: open[true] || 0, no: open[false] || 0 },
        closed: { yes: closed[true] || 0, no: closed[false] || 0 }
      }
    end
  end
end
