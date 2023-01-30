# frozen_string_literal: true

module Find
  module Courses
    module ApplyComponent
      class ViewPreview < ViewComponent::Preview
        def course_with_no_vacancies
          course = Course.new(course_code: 'FIND',
                              provider: Provider.new(provider_code: 'DFE'))

          SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_find_opens)
          render Find::Courses::ApplyComponent::View.new(course)
        end

        def course_with_vacancies
          course = Course.new(course_code: 'FIND',
                              provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current),
                              site_statuses: [SiteStatus.new(publish: 'published',
                                                             status: 'running')])

          # SiteSetting.set(name: "cycle_schedule", value: :today_is_after_find_opens)
          # Instead of doing the above, when the cycle switcher page is ported across we can make this work
          render Find::Courses::ApplyComponent::View.new(course)
        end

        def course_closed
          course = Course.new(course_code: 'FIND',
                              provider: Provider.new(provider_code: 'DFE'))

          # SiteSetting.set(name: "cycle_schedule", value: :today_is_after_find_closes)
          # Instead of doing the above, when the cycle switcher page is ported across we can make this work
          render Find::Courses::ApplyComponent::View.new(course)
        end
      end
    end
  end
end
