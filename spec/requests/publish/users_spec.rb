# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider users", type: :request do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:user) { create(:user, first_name: "Current", last_name: "User", providers: [provider], last_login_date_utc: 1.year.ago) }

  before { login_user(user) }

  describe "GET /publish/organisations/:code/users" do
    it "sorts by name and shows the managing users callout" do
      create(:user, first_name: "Zoe", last_name: "Zebra", providers: [provider], last_login_date_utc: 1.day.ago)
      create(:user, first_name: "Ada", last_name: "Aardvark", providers: [provider], last_login_date_utc: nil)

      get publish_provider_users_path(provider.provider_code)

      table = response.body[/<tbody.*?<\/tbody>/m]
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<strong>Name A to Z</strong>")
      expect(response.body).to include("Most recently signed in")
      expect(response.body).to include("Managing users")
      expect(response.body).to include("You can click &#39;Remove user&#39; to remove those who no longer work at your organisation, or need access to Publish.")
      expect(table.index("Ada Aardvark")).to be < table.index("Current User")
      expect(table.index("Current User")).to be < table.index("Zoe Zebra")
    end

    it "sorts by most recently signed in, with people who have never signed in last" do
      recent = create(:user, first_name: "Recent", last_name: "Person", providers: [provider], last_login_date_utc: 1.hour.ago)
      never = create(:user, first_name: "Never", last_name: "Signed", providers: [provider], last_login_date_utc: nil)

      get publish_provider_users_path(provider.provider_code, sort: "last_signed_in")

      table = response.body[/<tbody.*?<\/tbody>/m]
      expect(response.body).to include("<strong>Most recently signed in</strong>")
      expect(table.index(recent.full_name)).to be < table.index(never.full_name)
      expect(table.index(user.full_name)).to be < table.index(never.full_name)
    end

    it "shows 20 users on the first page" do
      create_list(:user, 20, providers: [provider])

      get publish_provider_users_path(provider.provider_code)

      expect(response.body.scan('class="govuk-table__row"').size).to eq(21)
    end
  end
end
