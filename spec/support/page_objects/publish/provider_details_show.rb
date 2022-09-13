module PageObjects
  module Publish
    class ProviderDetailsShow < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/details"

      element :title, ".govuk-heading-l"
      element :caption, ".govuk-caption-l"
      element :train_with_us_link, "[data-qa=enrichment__train_with_us] a"
      element :train_with_disability_link, "[data-qa=enrichment__train_with_disability] a"
      element :student_visa_link, "[data-qa=enrichment__can_sponsor_student_visa] a"
      element :skilled_worker_visa_link, "[data-qa=enrichment__can_sponsor_skilled_worker_visa] a"
      element :email_link, "[data-qa=enrichment__email] a"
    end
  end
end
