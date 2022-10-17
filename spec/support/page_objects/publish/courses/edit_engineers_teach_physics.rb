# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class EditEngineersTeachPhysics < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/engineers_teach_physics"

        section :campaign_fields, '[data-qa="course__engineers_teach_physics_radio_group"]' do
          element :engineers_teach_physics, '[data-qa="course__campaign_name_engineers_teach_physics_radio"]'
          element :no_campaign, '[data-qa="course__campaign_name_no_campaign_radio"]'
        end

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
