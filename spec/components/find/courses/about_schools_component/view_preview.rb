# frozen_string_literal: true

module Find
  module Courses
    module AboutSchoolsComponent
      class ViewPreview < ViewComponent::Preview
        def fee_based_course_selectable_school_active
          course = build_course(funding: 'fee', selectable_school: true)
          render Find::Courses::AboutSchoolsComponent::View.new(course)
        end

        def fee_based_course_no_selectable_school
          course = build_course(funding: 'fee', selectable_school: false)
          render Find::Courses::AboutSchoolsComponent::View.new(course)
        end

        def salaried_course_selectable_school_active
          course = build_course(funding: 'salary', selectable_school: true)
          render Find::Courses::AboutSchoolsComponent::View.new(course)
        end

        def salaried_course_no_selectable_school
          course = build_course(funding: 'salary', selectable_school: false)
          render Find::Courses::AboutSchoolsComponent::View.new(course)
        end

        private

        def build_course(funding:, selectable_school:)
          Course.new(
            course_code: 'FIND',
            provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current, selectable_school:),
            funding:,
            study_sites: [fake_study_site],
            sites: [fake_study_site],
            site_statuses: [SiteStatus.new(id: 2_245_455, course_id: 12_983_436, publish: 'published', site_id: 11_228_658, status: 'running', vac_status: 'part_time_vacancies'), SiteStatus.new(id: 22_454_556, course_id: 12_983_436, publish: 'published', site_id: 11_228_659, status: 'running', vac_status: 'part_time_vacancies')]
          ).decorate
        end

        def fake_study_site
          Site.new(id: 11_228_658, location_name: 'Study site', code: '1', address1: '1 Main Street', address2: 'Mainland', address3: 'Mainford', address4: 'Mainsville', postcode: 'MN1 1AA', region_code: 'london', site_type: :study_site)
        end
      end
    end
  end
end
