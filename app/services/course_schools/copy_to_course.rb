# frozen_string_literal: true

# Copies a course's placement schools onto a copy of that course under another
# provider.
#
# Only copy course schools to the new provider if the new provider has the
# provider schools
module CourseSchools
  class CopyToCourse
    def call(course:, new_provider:, new_course:)
      schools = schools_to_copy(course, new_provider)
      sites = paired_sites(schools, new_provider)

      schools.each do |provider_school|
        new_course.schools.create!(
          provider_school:,
          gias_school_id: provider_school.gias_school_id,
        )

        # TODO: School data remodel removal - delete when courses no longer dual-write to SiteStatus.
        Sites::CopyToCourseService.call(new_site: sites.fetch(provider_school.uuid), new_course:)
      end
    end

  private

    def schools_to_copy(course, new_provider)
      new_provider.schools.where(gias_school_id: course.schools.select(:gias_school_id)).to_a
    end

    def paired_sites(schools, new_provider)
      new_provider.sites.where(uuid: schools.map(&:uuid)).index_by(&:uuid)
    end
  end
end
