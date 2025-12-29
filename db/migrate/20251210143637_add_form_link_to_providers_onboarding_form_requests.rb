class AddFormLinkToProvidersOnboardingFormRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :providers_onboarding_form_request, :form_link, :string
  end
end
