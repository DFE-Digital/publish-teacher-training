# frozen_string_literal: true

module Find
  module Courses
    module ApplyComponent
      class ViewPreview < ViewComponent::Preview
        def course_open
          course = Course.new(course_code: 'FIND',
                              application_status: :open,
                              provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current),
                              site_statuses: [SiteStatus.new(publish: 'published',
                                                             status: 'running')])
          render Find::Courses::ApplyComponent::View.new(course)
        end

        def course_closed
          course = Course.new(course_code: 'FIND',
                              application_status: :closed,
                              provider: Provider.new(provider_code: 'DFE'))

          render Find::Courses::ApplyComponent::View.new(course)
        end
      end
    end
  end
end
