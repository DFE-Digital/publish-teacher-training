# frozen_string_literal: true

class AddProviderForeignKeyToProvidersOnboardingFormRequest < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :providers_onboarding_form_request, :provider, validate: false
  end
end
