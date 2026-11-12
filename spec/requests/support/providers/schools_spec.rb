# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support provider schools" do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:gias_school) do
    create(
      :gias_school,
      name: "St Joseph's Catholic Primary School",
      urn: "112992",
      address1: "1 School Lane",
      town: "Leeds",
      postcode: "LS1 1AA",
    )
  end
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
  end

  # These pages read Provider::School, so they are exercised with a provider
  # school that has no legacy Site mirroring it.
  describe "GET /support/:recruitment_cycle_year/providers/:provider_id/schools" do
    let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: "A") }

    it "lists the provider's schools" do
      create_list(:course, 2, provider:).each do |course|
        create(:course_school, course:, provider_school:, gias_school:)
      end

      get support_recruitment_cycle_provider_schools_path(recruitment_cycle.year, provider)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("View in Publish")
      expect(response.body).to include("St Joseph")
      expect(response.body).to include("Catholic Primary School")
      expect(response.body).to include("112992")

      school_row = response.parsed_body.at_css("tbody tr")
      expect(school_row.at_css(".name a")).to be_nil
      expect(school_row.at_css(".name .govuk-\\!-font-weight-bold").text.squish).to eq("St Joseph's Catholic Primary School")
      expect(school_row.at_css(".address").text.squish).to eq("1 School Lane, Leeds, LS1 1AA")
      expect(school_row.at_css(".courses-count").text.squish).to eq("2 courses")

      view_link = school_row.at_css(".view-in-publish a")
      expect(view_link.text.squish).to eq("View school St Joseph's Catholic Primary School")
      expect(view_link["href"]).to eq(
        publish_provider_recruitment_cycle_school_path(
          provider.provider_code,
          recruitment_cycle.year,
          provider_school.uuid,
          return_to: :support,
        ),
      )

      expect(response.body).to include("Add school in Publish")
      expect(response.body).to include("Add multiple schools in Publish")
      expect(response.body).to include(
        search_publish_provider_recruitment_cycle_schools_path(
          provider.provider_code,
          recruitment_cycle.year,
          return_to: "support",
        ),
      )
      expect(response.body).to include(
        new_publish_provider_recruitment_cycle_schools_multiple_path(
          provider.provider_code,
          recruitment_cycle.year,
          return_to: "support",
        ),
      )
    end
  end
end
