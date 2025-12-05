class CreateProvidersOnboardingFormRequest < ActiveRecord::Migration[8.0]
  def change
    create_table :providers_onboarding_form_request do |t|
      t.string :status, null: false, default: "pending"
      t.string :form_name, null: false
      t.string :zendesk_link
      t.uuid :uuid, null: false, default: -> { "uuid_generate_v4()" }
      t.jsonb :provider_metadata, default: {}
      t.string :email_address
      t.string :first_name
      t.string :last_name
      t.string :provider_name
      t.text :address_line_1
      t.text :address_line_2
      t.text :address_line_3
      t.string :town_or_city
      t.string :county
      t.string :postcode
      t.string :telephone
      t.string :contact_email_address
      t.string :website
      t.string :ukprn
      t.boolean :accredited_provider
      t.string :urn

      t.timestamps
    end

    # unique index on uuid for quick lookup
    add_index :providers_onboarding_form_request, :uuid, unique: true

    # link to User table for support_agent_id which is optional
    add_reference :providers_onboarding_form_request, :support_agent,
                  foreign_key: { to_table: :user, name: "FK_onboarding_request_user_support_agent_id" },
                  null: true
  end
end
