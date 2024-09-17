# frozen_string_literal: true

module Find
  module Courses
    module TrainingLocations
      class ViewPreview < ViewComponent::Preview
        def no_study_sites_and_one_placement
          course = Course.new(course_code: 'FIND',
                              sites: [Site.new],
                              provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def one_study_site_and_one_placement
          course = Course.new(course_code: 'FIND',
                              sites: [Site.new],
                              study_sites: [Site.new],
                              provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def two_study_sites_and_one_placement
          course = Course.new(course_code: 'FIND',
                              sites: [Site.new],
                              study_sites: [Site.new, Site.new],
                              provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def two_study_sites_and_two_placements
          course = Course.new(course_code: 'FIND',
                              sites: [Site.new, Site.new],
                              study_sites: [Site.new, Site.new],
                              provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end
      end
    end
  end
end
