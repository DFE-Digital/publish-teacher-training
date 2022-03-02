module Courses
  class CreationService
    include ServicePattern

    attr_reader :course_params, :provider, :next_available_course_code

    def initialize(course_params:, provider:, next_available_course_code: false)
      @course_params = course_params
      @provider = provider
      @next_available_course_code = next_available_course_code
    end

    def call
      build_new_course
    end

  private

    def new_course
      @new_course ||= provider.courses.new
    end

    def build_new_course
      course = provider.courses.new
      course.assign_attributes(course_attributes)

      update_subjects(course)
      update_sites(course)
      update_further_education_fields(course) if course.level == "further_education"

      course.course_code = provider.next_available_course_code if next_available_course_code
      course.name = course.generate_name

      course.valid?(:new)
      course.remove_carat_from_error_messages

      course
    end

    def course_attributes
      @course_attributes ||= course_params.to_h.symbolize_keys.slice(*permitted_new_course_attributes)
    end

    def permitted_new_course_attributes
      @permitted_new_course_attributes ||= CoursePolicy.new(nil, new_course).permitted_new_course_attributes
    end

    def subjects
      @subjects ||= Subject.find(subject_ids)
    end

    def sites
      @sites ||= provider.sites.find(site_ids)
    end

    def subject_ids
      @subject_ids ||= course_params["subjects_ids"]
    end

    def site_ids
      @site_ids ||= course_params["sites_ids"]
    end

    def update_subjects(course)
      return if subject_ids.nil?

      if request_has_duplicate_subject_ids?
        course.errors.add(:subjects, :duplicate)
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

    def update_sites(course)
      return if site_ids.nil?

      course.sites = sites if site_ids.any?

      course.errors.add(:sites, message: "Select at least one location") if site_ids.empty?
    end

    def update_further_education_fields(course)
      course.funding_type = "fee"
      course.english = "not_required"
      course.maths = "not_required"
      course.science = "not_required"
      course.subjects << FurtherEducationSubject.instance
    end
  end
end
