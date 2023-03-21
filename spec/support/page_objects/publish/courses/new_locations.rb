# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewLocations < PageObjects::Base
        set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/schools/new{?query*}'

        element :title, '[data-qa="page-heading"]'

        sections :locations, '.govuk-checkboxes__item' do
          element :name, '.govuk-checkboxes__label'
          element :checkbox, '.govuk-checkboxes__input'
        end

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
