# frozen_string_literal: true

class AddProviderTypeToProvidersOnboardingFormRequest < ActiveRecord::Migration[8.1]
  def change
    add_column :providers_onboarding_form_request, :provider_type, :string # rubocop:disable Rails/BulkChangeTable
    add_column :providers_onboarding_form_request, :accredited_provider_number, :string
  end
end
