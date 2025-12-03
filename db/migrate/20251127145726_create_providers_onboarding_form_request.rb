class CreateProvidersOnboardingFormRequest < ActiveRecord::Migration[8.0]
  def change
    create_table :providers_onboarding_form_request do |t|
      t.string :status, null: false, default: "pending"
      t.text :form_name, null: false
      t.bigint :support_agent_id
      t.string :zendesk_link
      t.uuid :uuid, null: false, default: -> { "uuid_generate_v4()" }
      t.jsonb :provider_metadata, default: {}
      t.text :email_address
      t.text :first_name
      t.text :last_name
      t.string :provider_name
      t.text :address_line_1
      t.text :address_line_2
      t.text :address_line_3
      t.text :town_or_city
      t.text :county
      t.text :postcode
      t.text :telephone
      t.text :contact_email_address
      t.text :website
      t.string :ukprn
      t.boolean :accredited_provider
      t.string :urn

      t.timestamps
    end

    # unique index on uuid for quick lookup
    add_index :providers_onboarding_form_request, :uuid, unique: true

    # link to User table for support_agent_id
    add_foreign_key :providers_onboarding_form_request, :user, column: :support_agent_id, name: "FK_onboarding_request_user_support_agent_id"
  end
end
