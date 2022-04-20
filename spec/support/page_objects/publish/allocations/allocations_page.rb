# frozen_string_literal: true

require_relative "../../sections/errorlink"

module PageObjects
  module Publish
    module Allocations
      class AllocationsPage < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations"

        sections :rows, "tbody tr" do
          element :provider_name, '[data-qa="provider-name"]'
          element :allocation_number, '[data-qa="confirmed-places"]'
          element :uplift_number, '[data-qa="uplifts"]'
          element :total_number, '[data-qa="total"]'
          element :status, '[data-qa="status"]'
        end

        sections :repeat_allocations, '[data-qa="repeat-allocations-table"]' do
          element :provider_name, '[data-qa="provider-name"]'
          element :status, '[data-qa="status"]'
          element :actions, '[data-qa="actions"]'
        end

        sections :initial_allocations, '[data-qa="initial-allocations-table"]' do
          element :provider_name, '[data-qa="provider-name"]'
          element :status, '[data-qa="status"]'
          element :actions, '[data-qa="actions"]'
        end
      end
    end
  end
end
