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
          ordered_subject_ids.each_with_index do |subject_id, index|
            course.course_subjects.create(subject_id:, position: index)
          end
          course.save
        end
      else
        ordered_subject_ids.each_with_index do |subject_id, index|
          course.course_subjects.build(subject_id:, position: index)
        end
      end
    end

    def ordered_subject_ids
      subjects_by_id = subjects.index_by(&:id)

      language_ids = subject_ids.select { |id| subjects_by_id[id].is_a?(ModernLanguagesSubject) }
      return subject_ids if language_ids.empty?

      non_language_ids = subject_ids - language_ids

      ml_parent_index = non_language_ids.index do |id|
        s = subjects_by_id[id]
        s.is_a?(SecondarySubject) && s.subject_name == "Modern Languages"
      end

      return subject_ids unless ml_parent_index

      non_language_ids.insert(ml_parent_index + 1, *language_ids)
    end

    def assign_master_and_subordinate_subject_ids
      return if subject_ids.empty?

      language_ids = subjects.select { |s| s.is_a?(ModernLanguagesSubject) }.map(&:id)
      non_language_ids = subject_ids.reject { |id| language_ids.include?(id) }
      course.master_subject_id, course.subordinate_subject_id = non_language_ids
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
