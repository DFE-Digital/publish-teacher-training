class RemoveFormLinkFromProvidersOnboardingFormRequests < ActiveRecord::Migration[8.0]
  def change
    remove_column :providers_onboarding_form_request, :form_link, :string
  end
end
