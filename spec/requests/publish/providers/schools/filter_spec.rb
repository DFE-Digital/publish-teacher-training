# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider schools filter suggestions", service: :publish do
  include DfESignInUserHelper

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:provider) { create(:provider, recruitment_cycle:) }

  def suggestions_path(query)
    filter_publish_provider_recruitment_cycle_schools_path(
      provider.provider_code,
      recruitment_cycle.year,
      query:,
    )
  end

  before { login_user(create(:user, providers: [provider])) }

  it "suggests the provider's schools matching the filter" do
    create(
      :provider_school,
      provider:,
      gias_school: create(:gias_school, name: "Bramblewood Primary", town: "Leeds", postcode: "LS1 1AA"),
    )
    create(:provider_school, provider:, gias_school: create(:gias_school, name: "Harborne Academy"))

    get suggestions_path("Bramblewood")

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(
      [{ "name" => "Bramblewood Primary", "town" => "Leeds", "postcode" => "LS1 1AA" }],
    )
  end

  it "does not suggest another provider's schools" do
    create(
      :provider_school,
      provider: create(:provider, recruitment_cycle:),
      gias_school: create(:gias_school, name: "Bramblewood Primary"),
    )

    get suggestions_path("Bramblewood")

    expect(response.parsed_body).to be_empty
  end

  it "rejects a filter shorter than three characters" do
    get suggestions_path("Br")

    expect(response).to have_http_status(:bad_request)
  end

  it "keeps the filter on the index's pagination links" do
    stub_const("Publish::Providers::SchoolsController::PER_PAGE", 1)
    create(:provider_school, provider:, gias_school: create(:gias_school, name: "Bramblewood Primary"))
    create(:provider_school, provider:, gias_school: create(:gias_school, name: "Bramblewood Secondary"))

    get publish_provider_recruitment_cycle_schools_path(
      provider.provider_code, recruitment_cycle.year, filter: "Bramblewood"
    )

    expect(response.body).to include("Bramblewood Primary")
    expect(response.body).not_to include("Bramblewood Secondary")
    expect(response.body).to include("page=2&amp;filter=Bramblewood").or include("filter=Bramblewood&amp;page=2")
  end

  it "forbids a user who does not belong to the provider" do
    login_user(create(:user, providers: [create(:provider, recruitment_cycle:)]))

    get suggestions_path("Bramblewood")

    expect(response).to have_http_status(:forbidden)
  end
end
