module PageObjects
  module Publish
    class ProviderDetailsEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/about"

      element :error_summary, ".govuk-error-summary"
      element :training_with_you_field, "textarea[name=\"publish_about_your_organisation_form[train_with_us]\"]"
      element :accredited_body_description_field, "textarea[name=\"publish_about_your_organisation_form[accredited_bodies][][description]\"]"
      element :train_with_disability_field, "textarea[name=\"publish_about_your_organisation_form[train_with_disability]\"]"

      element :save_and_publish, ".govuk-button"
    end
  end
end
