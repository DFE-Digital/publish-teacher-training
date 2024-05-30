# frozen_string_literal: true

module Courses
  class AssignSubjectsService
    include ServicePattern

    attr_reader :course, :subject_ids

    def initialize(course:, subject_ids:)
      @course = course
      course.master_subject_id, course.subordinate_subject_id = subject_ids
      @subject_ids = subject_ids&.compact_blank || []
    end

    def call
      if request_has_duplicate_subject_ids?
        course.errors.add(:subjects, :duplicate)
        return course
      end

      if course.master_subject_id.nil? && !course.further_education_course?
        course.errors.add(:subjects, :course_creation)
        return course
      end

      update_subjects

      if course.persisted?
        course.name = course.generate_name if course.valid?
      else
        course.name = course.generate_name
      end

      course
    end

    private

    def subjects
      @subjects ||= Subject.find(@subject_ids)
    end

    def update_subjects
      if course.further_education_course?
        update_further_education_fields

        course
          .course_subjects
          .build(subject_id: FurtherEducationSubject.instance.id)

      elsif course.persisted?
        Course.transaction do
          course.course_subjects.clear
          subject_ids.each do |subject_id|
            course.course_subjects.create(subject_id:)
          end
          course.save
        end
      else
        subject_ids.each do |subject_id|
          course.course_subjects.build(subject_id:)
        end
      end
    end

    def request_has_duplicate_subject_ids?
      subject_ids.uniq.count != subject_ids.count
    end

    def update_further_education_fields
      course.funding_type = 'fee'
      course.english = 'not_required'
      course.maths = 'not_required'
      course.science = 'not_required'
    end
  end
end
