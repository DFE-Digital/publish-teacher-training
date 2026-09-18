# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class SchoolShow < PageObjects::Base
        set_url "/support/{recruitment_cycle_year}/providers/{provider_id}/schools/{id}"

        element :change_name, "a.govuk-link.location_name", text: "Change"

        element :remove_school_link, ".app-link--destructive"
      end
    end
  end
end
