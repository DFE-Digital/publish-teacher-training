# frozen_string_literal: true

require_relative "../sections/training_partner"

module PageObjects
  module Publish
    class TrainingPartnerIndex < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/training-partners"

      sections :training_provider_rows, Sections::TrainingPartner, '[data-qa="provider__training_partners_list"]'
    end
  end
end
