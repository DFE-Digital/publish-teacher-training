# frozen_string_literal: true

module Find
  module Courses
    module AboutSchoolsComponent
      class ViewPreview < ViewComponent::Preview
        def hei_minimum
          course = Course.new(course_code: 'FIND',
                              provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current),
                              program_type: 'higher_education_programme',
                              level: 'further_education').decorate
          render Find::Courses::AboutSchoolsComponent::View.new(course)
        end

        def scitt_minimum
          course = Course.new(course_code: 'FIND',
                              provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current),
                              program_type: 'scitt_programme',
                              level: 'secondary').decorate
          render Find::Courses::AboutSchoolsComponent::View.new(course)
        end

        def scitt_with_placements_and_sites
          render Find::Courses::AboutSchoolsComponent::View.new(mock_scitt_course)
        end

        def hei_with_placements_and_sites
          render Find::Courses::AboutSchoolsComponent::View.new(mock_hei_course)
        end

        private

        def mock_scitt_course
          FakeCourse.new(provider: Provider.new(provider_code: 'DFE'),
                         how_school_placements_work: 'you will go on placement and learn more',
                         placements_heading: 'Teaching placements',
                         program_type: 'scitt_programme',
                         site_statuses: [SiteStatus.new(id: 2_245_455, course_id: 12_983_436, publish: 'published', site_id: 11_228_658, status: 'running'), SiteStatus.new(id: 22_454_556, course_id: 12_983_436, publish: 'published', site_id: 11_228_659, status: 'running')])
        end

        def mock_hei_course
          FakeCourse.new(provider: Provider.new(provider_code: 'DFE'),
                         how_school_placements_work: 'you will go on placement and learn more',
                         placements_heading: 'Teaching placements',
                         program_type: 'higher_education_programme',
                         site_statuses: [SiteStatus.new(id: 2_245_455, course_id: 12_983_436, publish: 'published', site_id: 11_228_658, status: 'running'), SiteStatus.new(id: 22_454_556, course_id: 12_983_436, publish: 'published', site_id: 11_228_659, status: 'running')])
        end

        class FakeCourse
          include ActiveModel::Model
          attr_accessor(:provider, :how_school_placements_work, :placements_heading, :program_type, :site_statuses)

          def preview_site_statuses
            site_statuses.sort_by { |status| status.site.location_name }
          end
        end
      end
    end
  end
end
