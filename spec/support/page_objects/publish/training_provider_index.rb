# frozen_string_literal: true

require_relative "../sections/training_provider"

module PageObjects
  module Publish
    class TrainingProviderIndex < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/training-providers"

      sections :training_provider_rows, Sections::TrainingProvider, '[data-qa="provider__training_providers_list"]'
    end
  end
end
