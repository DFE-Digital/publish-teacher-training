# frozen_string_literal: true

module Find
  module Courses
    module TrainingLocations
      class ViewPreview < ViewComponent::Preview
        def no_study_sites_and_one_placement_fee_paying
          course = Course.new(course_code: "FIND",
                              sites: [Site.new],
                              funding: "fee",
                              provider: Provider.new(provider_code: "DFE", recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def one_study_site_and_one_placement_fee_paying
          course = Course.new(course_code: "FIND",
                              sites: [Site.new],
                              funding: "fee",
                              study_sites: [Site.new],
                              provider: Provider.new(provider_code: "DFE", recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def two_study_sites_and_one_placement_fee_paying
          course = Course.new(course_code: "FIND",
                              sites: [Site.new],
                              funding: "fee",
                              study_sites: [Site.new, Site.new],
                              provider: Provider.new(provider_code: "DFE", recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def two_study_sites_and_two_placements_fee_paying
          course = Course.new(course_code: "FIND",
                              sites: [Site.new, Site.new],
                              funding: "fee",
                              study_sites: [Site.new, Site.new],
                              provider: Provider.new(provider_code: "DFE", recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def no_study_sites_and_one_placement_salaried
          course = Course.new(course_code: "FIND",
                              funding: "salary",
                              sites: [Site.new],
                              provider: Provider.new(provider_code: "DFE", recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def one_study_site_and_one_placement_salaried
          course = Course.new(course_code: "FIND",
                              sites: [Site.new],
                              funding: "salary",
                              study_sites: [Site.new],
                              provider: Provider.new(provider_code: "DFE", recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def two_study_sites_and_one_placement_salaried
          course = Course.new(course_code: "FIND",
                              sites: [Site.new],
                              funding: "salary",
                              study_sites: [Site.new, Site.new],
                              provider: Provider.new(provider_code: "DFE", recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def two_study_sites_and_two_placements_salaried
          course = Course.new(course_code: "FIND",
                              sites: [Site.new, Site.new],
                              funding: "salary",
                              study_sites: [Site.new, Site.new],
                              provider: Provider.new(provider_code: "DFE", recruitment_cycle: RecruitmentCycle.current)).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def show_training_locations_school_placements_link_disabled
          course = Course.new(course_code: "FIND",
                              sites: [Site.new, Site.new],
                              funding: "salary",
                              study_sites: [Site.new, Site.new],
                              provider: Provider.new(provider_code: "DFE", selectable_school: false, recruitment_cycle: FactoryBot.build(:recruitment_cycle))).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end

        def show_training_locations_school_placements_link_enabled
          course = Course.new(course_code: "FIND",
                              sites: [Site.new, Site.new],
                              funding: "salary",
                              study_sites: [Site.new, Site.new],
                              provider: Provider.new(provider_code: "DFE", selectable_school: true, recruitment_cycle: FactoryBot.build(:recruitment_cycle))).decorate
          render Find::Courses::TrainingLocations::View.new(course:)
        end
      end
    end
  end
end
