class CreateProvidersOnboardingFormRequest < ActiveRecord::Migration[8.0]
  def change
    create_table :providers_onboarding_form_request do |t|
      t.string :status, null: false, default: "pending"
      t.text :form_name, null: false
      t.bigint :support_agent_id
      t.string :zendesk_link
      t.uuid :uuid, null: false, default: -> { "uuid_generate_v4()" }
      t.jsonb :provider_metadata, default: {}
      t.text :email_address, null: false
      t.text :first_name, null: false
      t.text :last_name, null: false
      t.string :organisation_name, null: false
      t.text :address_line_1, null: false
      t.text :address_line_2
      t.text :address_line_3
      t.text :town_or_city, null: false
      t.text :county
      t.text :postcode, null: false
      t.text :phone_number, null: false
      t.text :contact_email_address, null: false
      t.text :organisation_website, null: false
      t.string :ukprn, null: false
      t.boolean :accredited_provider, null: false
      t.string :urn, null: false

      t.timestamps
    end

    # unique index on uuid for quick lookup
    add_index :providers_onboarding_form_request, :uuid, unique: true

    # link to User table for support_agent_id
    add_foreign_key :providers_onboarding_form_request, :user, column: :support_agent_id, name: "FK_onboarding_request_user_support_agent_id"
  end
end
