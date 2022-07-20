module PageObjects
  module Publish
    class DraftRollover < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/rollover?"

      element :rollover_course_button, '[data-qa="course__rollover-course"]'
    end
  end
end
