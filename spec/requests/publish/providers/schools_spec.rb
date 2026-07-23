# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider school show", travel: mid_cycle do
  include DfESignInUserHelper

  let(:user) { create(:user, providers: [provider]) }
  let(:gias_school) do
    create(
      :gias_school,
      name: "Springfield Primary",
      urn: "123456",
      address1: "1 High Street",
      town: "London",
      county: "Greater London",
      postcode: "SW1A 1AA",
    )
  end
  let(:site) { create(:site, provider:, code: "AB", **gias_school.school_attributes) }
  let(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: site.code) }
  let(:provider) { create(:provider) }

  before do
    site
    provider_school
    login_user(user)
  end

  describe "GET show on the current recruitment cycle" do
    let(:show_path) do
      publish_provider_recruitment_cycle_school_path(
        provider.provider_code,
        provider.recruitment_cycle.year,
        site.id,
      )
    end

    it "displays legacy site details" do
      get show_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Springfield Primary")
      expect(response.body).to include("AB")
      expect(response.body).to include("123456")
      expect(response.body).to include("1 High Street")
    end
  end

  describe "GET show on a future recruitment cycle" do
    let(:recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let(:show_path) do
      publish_provider_recruitment_cycle_school_path(
        provider.provider_code,
        provider.recruitment_cycle.year,
        provider_school.id,
      )
    end

    it "displays provider school details from the new model" do
      get show_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Springfield Primary")
      expect(response.body).to include("AB")
      expect(response.body).to include("123456")
      expect(response.body).to include("1 High Street")
    end

    context "when the school is a main site" do
      let(:site) { create(:site, :main_site, provider:, **gias_school.school_attributes) }
      let(:provider_school) do
        create(:provider_school, :main_site, provider:, gias_school:, site_code: site.code)
      end

      it "displays the main site suffix" do
        get show_path

        expect(response.body).to include("Springfield Primary (Main Site)")
      end
    end

    context "when the provider has duplicate GIAS relationships" do
      let(:main_site) do
        create(
          :provider_school,
          :main_site,
          provider:,
          gias_school:,
          site_code: Provider::School::MAIN_SITE_CODE,
        )
      end

      before { main_site }

      it "loads each provider school by its own id" do
        get publish_provider_recruitment_cycle_school_path(
          provider.provider_code,
          provider.recruitment_cycle.year,
          main_site.id,
        )
        expect(response.body).to include("Springfield Primary (Main Site)")

        get show_path
        expect(response.body).to include(
          '<h1 class="govuk-fieldset__heading govuk-!-margin-bottom-3">Springfield Primary</h1>',
        )
      end
    end

    context "when the provider school belongs to another provider" do
      let(:other_provider_school) { create(:provider_school) }

      it "returns not found" do
        get publish_provider_recruitment_cycle_school_path(
          provider.provider_code,
          provider.recruitment_cycle.year,
          other_provider_school.id,
        )

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the provider school belongs to another recruitment cycle" do
      let(:current_cycle) { find_or_create(:recruitment_cycle) }
      let(:current_provider) { create(:provider, provider_code: provider.provider_code, recruitment_cycle: current_cycle) }
      let(:current_provider_school) { create(:provider_school, provider: current_provider, gias_school:) }

      before { current_provider_school }

      it "returns not found" do
        get publish_provider_recruitment_cycle_school_path(
          provider.provider_code,
          provider.recruitment_cycle.year,
          current_provider_school.id,
        )

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the id is invalid" do
      it "returns not found" do
        get publish_provider_recruitment_cycle_school_path(
          provider.provider_code,
          provider.recruitment_cycle.year,
          0,
        )

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET index" do
    let(:index_path) { publish_provider_recruitment_cycle_schools_path(provider.provider_code, provider.recruitment_cycle.year) }

    it "uses legacy site links on the current cycle" do
      get index_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        publish_provider_recruitment_cycle_school_path(
          provider.provider_code,
          provider.recruitment_cycle.year,
          site.id,
        ),
      )
      expect(response.body).not_to include(
        publish_provider_recruitment_cycle_school_path(
          provider.provider_code,
          provider.recruitment_cycle.year,
          provider_school.id,
        ),
      )
    end

    context "on a future recruitment cycle" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
      let(:provider) { create(:provider, recruitment_cycle:) }

      it "links to the provider school show page" do
        get index_path

        expect(response.body).to include(
          publish_provider_recruitment_cycle_school_path(
            provider.provider_code,
            provider.recruitment_cycle.year,
            provider_school.id,
          ),
        )
        expect(response.body).to include("Springfield Primary")
      end

      context "when the school is a main site" do
        let(:site) { create(:site, :main_site, provider:, **gias_school.school_attributes) }
        let(:provider_school) do
          create(:provider_school, :main_site, provider:, gias_school:, site_code: site.code)
        end

        it "displays the GIAS name with the main site suffix" do
          get index_path

          expect(response.body).to include("Springfield Primary (Main Site)")
        end
      end

      context "when a legacy site has no matching provider school" do
        before { provider_school.destroy! }

        it "renders a message when no matching provider school exists" do
          get index_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Springfield Primary")
          expect(response.body).to include("No new school model data")
        end
      end
    end
  end
end
