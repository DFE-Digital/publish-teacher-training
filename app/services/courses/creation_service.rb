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
      course.assign_attributes(course_attributes.except(:subjects_ids))

      update_sites(course)

      course.course_code = provider.next_available_course_code if next_available_course_code

      AssignSubjectsService.call(course:, subject_ids:)

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

    def sites
      @sites ||= provider.sites.find(site_ids)
    end

    def subject_ids
      @subject_ids ||= course_params["subjects_ids"]
    end

    def site_ids
      @site_ids ||= course_params["sites_ids"]
    end

    def update_sites(course)
      return if site_ids.nil?

      course.sites = sites if site_ids.any?

      course.errors.add(:sites, message: "Select at least one location") if site_ids.empty?
    end
  end
end
