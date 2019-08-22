module Courses
  class CopyToProviderService
    def initialize(sites_copy_to_course:)
      @sites_copy_to_course = sites_copy_to_course
    end

    def execute(course:, new_provider:)
      new_course = new_provider.courses.find_by(course_code: course.course_code)

      return nil if new_course.present?

      new_course = nil

      Course.transaction do
        new_course = course.dup
        new_course.provider = new_provider
        new_course.save!

        new_course.subjects << course.subjects

        last_enrichment = course.enrichments.latest_first.first
        last_enrichment.copy_to_course(new_course) if last_enrichment.present?

        course.sites.each do |site|
          new_site = new_provider.sites.find_by(code: site.code)

          @sites_copy_to_course.execute(new_site: new_site, new_course: new_course) if new_site.present?
        end
      end

      new_course
    end
  end
end
