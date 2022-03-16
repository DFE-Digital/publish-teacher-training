module Courses
  class AssignSubjectsService
    include ServicePattern

    attr_reader :course, :subject_ids

    def initialize(course:, subject_ids:)
      @course = course
      @subject_ids = subject_ids || []
    end

    def call
      course.errors.add(:subjects, :duplicate) if request_has_duplicate_subject_ids?

      update_subjects

      course.name = course.generate_name
      course
    end

    def subjects
      @subjects ||= Subject.find(@subject_ids)
    end

    def update_subjects
      if course.further_education_course?
        update_further_education_fields

        course.subjects = [FurtherEducationSubject.instance]
        course.course_subjects.first.position = 1

      else
        course.subjects = subjects

        subject_ids.each_with_index do |id, index|
          course.course_subjects.select { |cs| cs.subject_id == id.to_i }.first.position = index
        end
      end
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
