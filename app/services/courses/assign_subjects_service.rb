# frozen_string_literal: true

module Courses
  class AssignSubjectsService
    include ServicePattern

    attr_reader :course, :subject_ids

    def initialize(course:, subject_ids:)
      @course = course
      @subject_ids = subject_ids&.compact_blank&.map(&:to_i) || []
      assign_master_and_subordinate_subject_ids
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

    def update_subjects
      if course.further_education_course?
        update_further_education_fields

        course
          .course_subjects
          .build(subject_id: FurtherEducationSubject.instance.id, position: 0)

      elsif course.persisted?
        Course.transaction do
          course.course_subjects.clear
          subject_ids.each_with_index do |subject_id, index|
            course.course_subjects.create(subject_id:, position: index)
          end
          course.save
        end
      else
        subject_ids.each_with_index do |subject_id, index|
          course.course_subjects.build(subject_id:, position: index)
        end
      end
    end

    def assign_master_and_subordinate_subject_ids
      return if subject_ids.empty?

      parent_ids = subject_ids.select { |id| assignable_parent_ids.include?(id) }
      course.master_subject_id, course.subordinate_subject_id = parent_ids
    end

    def assignable_parent_ids
      @assignable_parent_ids ||= course.assignable_master_subjects&.pluck(:id) || []
    end

    def request_has_duplicate_subject_ids?
      subject_ids.uniq.count != subject_ids.count
    end

    def update_further_education_fields
      course.funding_type = "fee"
      course.english = "not_required"
      course.maths = "not_required"
      course.science = "not_required"
    end
  end
end
