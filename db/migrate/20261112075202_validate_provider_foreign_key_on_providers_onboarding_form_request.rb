# frozen_string_literal: true

class ValidateProviderForeignKeyOnProvidersOnboardingFormRequest < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :providers_onboarding_form_request, :provider
  end
end
