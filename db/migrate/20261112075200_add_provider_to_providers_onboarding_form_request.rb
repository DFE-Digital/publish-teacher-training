# frozen_string_literal: true

class AddProviderToProvidersOnboardingFormRequest < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :providers_onboarding_form_request, :provider,
                  null: true,
                  index: { unique: true, algorithm: :concurrently }
  end
end
