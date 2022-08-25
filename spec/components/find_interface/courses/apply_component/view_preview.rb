# frozen_string_literal: true

module FindInterface::Courses::ApplyComponent
  class ViewPreview < ViewComponent::Preview
    def course_with_no_vacancies
      course = Course.new(course_code: "FIND",
        provider: Provider.new(provider_code: "DFE"))

      SiteSetting.set(name: "cycle_schedule", value: :today_is_after_find_opens)
      render FindInterface::Courses::ApplyComponent::View.new(course)
    end

    def course_with_vacancies
      course = Course.new(course_code: "FIND",
        provider: Provider.new(provider_code: "DFE"),
        site_statuses: [SiteStatus.new(publish: "published",
          status: "running")])

      SiteSetting.set(name: "cycle_schedule", value: :today_is_after_find_opens)
      render FindInterface::Courses::ApplyComponent::View.new(course)
    end

    def course_closed
      course = Course.new(course_code: "FIND",
        provider: Provider.new(provider_code: "DFE"))

      SiteSetting.set(name: "cycle_schedule", value: :today_is_after_find_closes)
      render FindInterface::Courses::ApplyComponent::View.new(course)
    end
  end
end
