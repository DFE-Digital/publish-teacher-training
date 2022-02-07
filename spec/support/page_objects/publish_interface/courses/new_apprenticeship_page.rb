# frozen_string_literal: true

module PageObjects
  module PublishInterface
    module Courses
      class NewApprenticeship < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/apprenticeship/new{?query*}"

        element :yes, '[data-qa="course__funding_type_apprenticeship"]'
        element :no, '[data-qa="course__funding_type_fee"]'

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
