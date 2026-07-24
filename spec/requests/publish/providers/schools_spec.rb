# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider school show page", service: :publish do
  include DfESignInUserHelper

  let(:remodel_cycle_year) { Settings.schools_remodel_cycle_year }
  let(:gias_school) do
    create(
      :gias_school,
      name: "St Joseph's Catholic Primary School",
      urn: "112992",
      address1: "1 School Lane",
      address2: "Building A",
      address3: "Quarter B",
      town: "Leeds",
      county: "West Yorkshire",
      postcode: "LS1 1AA",
    )
  end

  before do
    allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
  end

  def login_provider_user(provider)
    login_user(create(:user, providers: [provider]))
  end

  describe "GET /publish/organisations/:provider_code/:recruitment_cycle_year/schools" do
    context "when the provider is in the schools remodel cycle" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: SecureRandom.uuid) }
      let!(:provider_school) do
        create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)
      end

      before { login_provider_user(provider) }

      it "lists provider schools resolved from the new model" do
        get publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("St Joseph")
        expect(response.body).to include("Catholic Primary School")
        expect(response.body).to include("A")
        expect(response.body).to include("112992")
        expect(response.body).to include(publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid))
      end
    end
  end

  describe "GET /publish/organisations/:provider_code/:recruitment_cycle_year/schools/:uuid" do
    context "when the provider is in the schools remodel cycle" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: SecureRandom.uuid) }
      let!(:provider_school) do
        create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)
      end

      before { login_provider_user(provider) }

      it "displays the provider school resolved from the legacy site uuid" do
        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, site.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("St Joseph")
        expect(response.body).to include("Catholic Primary School")
        expect(response.body).to include("School code")
        expect(response.body).to include("A")
        expect(response.body).to include("112992")
        expect(response.body).to include("1 School Lane")
      end

      it "returns not found when the provider school does not exist" do
        provider_school.destroy!

        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, site.uuid)

        expect(response).to have_http_status(:not_found)
      end

      it "returns not found for another provider's school" do
        other_provider_school = create(:provider_school)

        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, other_provider_school.uuid)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the provider is after the schools remodel cycle" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year + 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: "B") }

      before { login_provider_user(provider) }

      it "displays the provider school" do
        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("St Joseph")
        expect(response.body).to include("Catholic Primary School")
        expect(response.body).to include("B")
      end

      it "returns not found for a school in another recruitment cycle" do
        other_cycle_school = create(
          :provider_school,
          provider: create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: remodel_cycle_year)),
        )

        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, other_cycle_school.uuid)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the same GIAS school is linked twice" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year + 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:normal_provider_school) { create(:provider_school, provider:, gias_school:, site_code: "A") }
      let!(:main_provider_school) { create(:provider_school, :main_site, provider:, gias_school:) }

      before { login_provider_user(provider) }

      it "displays the normal school without the main site suffix" do
        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, normal_provider_school.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("St Joseph")
        expect(response.body).to include("Catholic Primary School")
        expect(response.body).not_to include("(Main Site)")
      end

      it "displays the main site with the suffix" do
        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, main_provider_school.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("(Main Site)")
        expect(response.body).to include("-")
      end
    end
  end

  describe "GET /publish/organisations/:provider_code/:recruitment_cycle_year/schools/:uuid/delete" do
    let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year + 1) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let!(:provider_school) { create(:provider_school, provider:, gias_school:) }

    before { login_provider_user(provider) }

    it "displays the delete page for the provider school" do
      get delete_publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Remove school")
      expect(response.body).to include("St Joseph")
      expect(response.body).to include("Catholic Primary School")
    end
  end
end
