# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support provider users" do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
  end

  describe "GET /support/:year/providers/:id/users" do
    it "sorts by name and does not show the Publish managing users callout" do
      create(:user, first_name: "Zoe", last_name: "Zebra", providers: [provider])
      create(:user, first_name: "Ada", last_name: "Aardvark", providers: [provider])

      get support_recruitment_cycle_provider_users_path(provider.recruitment_cycle_year, provider)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<strong>Name A to Z</strong>")
      expect(response.body).to include("Most recently signed in")
      expect(response.body).not_to include("Managing users")
      expect(response.body.index("Ada Aardvark")).to be < response.body.index("Zoe Zebra")
    end

    it "sorts by most recently signed in, with people who have never signed in last" do
      recent = create(:user, first_name: "Recent", last_name: "Person", providers: [provider], last_login_date_utc: 1.hour.ago)
      never = create(:user, first_name: "Never", last_name: "Signed", providers: [provider], last_login_date_utc: nil)

      get support_recruitment_cycle_provider_users_path(provider.recruitment_cycle_year, provider, sort: "last_signed_in")

      expect(response.body).to include("<strong>Most recently signed in</strong>")
      expect(response.body.index(recent.full_name)).to be < response.body.index(never.full_name)
    end

    it "shows 20 users on the first page" do
      create_list(:user, 21, providers: [provider])

      get support_recruitment_cycle_provider_users_path(provider.recruitment_cycle_year, provider)

      expect(response.body.scan('class="govuk-table__row user-row"').size).to eq(20)
    end
  end
end
