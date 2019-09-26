module Courses
  class CopyToProviderService
    def initialize(sites_copy_to_course:, enrichments_copy_to_course:)
      @sites_copy_to_course = sites_copy_to_course
      @enrichments_copy_to_course = enrichments_copy_to_course
    end

    def execute(course:, new_provider:)
      return nil if course_code_already_exists_on_provider?(course: course, new_provider: new_provider)

      new_course = nil

      Course.transaction do
        new_course = course.dup
        new_course.provider = new_provider
        new_course.save!

        new_course.ucas_subjects << course.ucas_subjects

        copy_latest_enrichment_to_course(course, new_course)

        course.sites.each do |site|
          new_site = new_provider.sites.find_by(code: site.code)

          @sites_copy_to_course.execute(new_site: new_site, new_course: new_course) if new_site.present?
        end
      end

      new_course
    end

  private

    def course_code_already_exists_on_provider?(course:, new_provider:)
      new_provider.courses.with_discarded.where(course_code: course.course_code).any?
    end

    def copy_latest_enrichment_to_course(course, new_course)
      last_enrichment = course.enrichments.latest_first.first
      return if last_enrichment.blank?

      @enrichments_copy_to_course.execute(enrichment: last_enrichment, new_course: new_course)
    end
  end
end
