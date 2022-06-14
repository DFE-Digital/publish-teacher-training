# frozen_string_literal: true

require_relative "../../../sections/radio_button"

module PageObjects
  module Publish
    module Allocations
      module Request
        class WhoAreYouRequestingACourseFor < PageObjects::Base
          set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations/request"

          element :header, "h1"

          sections :radio_buttons, Sections::RadioButton, ".govuk-radios__item"

          element :continue, ".govuk-button"

          element :training_provider_search, "#training-provider-query-field"

          def providers
            @providers ||= radio_buttons.reject { |x| x == find_an_organisation_not_listed_above }
          end

          def find_an_organisation_not_listed_above
            @find_an_organisation_not_listed_above ||= radio_buttons.find { |x| x.text == "Find an organisation not listed above" }
          end
        end
      end
    end
  end
end
