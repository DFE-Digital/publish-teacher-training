require "rails_helper"

RSpec.describe "Publish - Providers - Removed Schools page", service: :publish, type: :system do
  include DfESignInUserHelper

  let(:site_attributes) do
    {
      location_name: "Gamma School",
      address1: "Gamma Street",
      address2: "Maple Lane",
      address3: "",
      address4: "",
      town: "Gammatown",
      postcode: "RB0 1AN",
      discarded_via_script: true,
    }
  end

  let(:provider) { create(:provider, provider_name: "Test Provider", provider_code: "ABC") }
  let!(:site_one) { create(:site, provider:, **site_attributes) }
  let!(:site_two) do
    create(
      :site,
      provider:,
      location_name: "Delta Academy",
      address1: "789 Delta Road",
      address2: "South Ridge",
      address3: "",
      address4: "",
      town: "Deltatown",
      postcode: "PL2 9BD",
      discarded_via_script: true,
    )
  end
  let!(:site_three) do
    create(
      :site,
      provider:,
      discarded_via_script: false,
      location_name: "Not Shown",
    )
  end
  let(:user) { create(:user, providers: [provider]) }
  let(:removed_schools_path) do
    removed_schools_publish_provider_recruitment_cycle_schools_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle.year,
    )
  end

  context "when the 2026 cycle has not yet started" do
    let(:frozen_time) { Time.zone.local(2025, 6, 1, 12, 0, 0) }
    let!(:recruitment_cycle) do
      create(:recruitment_cycle, year: 2026, application_start_date: frozen_time + 2.months)
    end

    before do
      given_time_is_frozen
      and_provider_is_linked_to_recruitment_cycle
      and_user_is_signed_in
    end

    after { travel_back }

    scenario "shows the removed schools" do
      when_i_visit_the_removed_schools_page
      then_i_see_the_heading_with_count(2)
      and_i_see_removed_school "Gamma School", "Gamma Street, Maple Lane, Gammatown, RB0 1AN"
      and_i_see_removed_school "Delta Academy", "789 Delta Road, South Ridge, Deltatown, PL2 9BD"
      and_i_do_not_see_site "Not Shown"
    end
  end

  context "when the 2026 cycle has started" do
    let(:frozen_time) { Time.zone.local(2025, 6, 1, 12, 0, 0) }
    let!(:recruitment_cycle) do
      create(:recruitment_cycle, year: 2026, application_start_date: frozen_time - 1.day)
    end

    before do
      given_time_is_frozen
      and_provider_is_linked_to_recruitment_cycle
      and_user_is_signed_in
    end

    after { travel_back }

    scenario "returns a 404 page" do
      when_i_visit_the_removed_schools_page
      then_i_see_a_404_page
    end
  end

private

  def given_time_is_frozen
    travel_to frozen_time
  end

  def and_provider_is_linked_to_recruitment_cycle
    provider.update!(recruitment_cycle:)
  end

  def and_user_is_signed_in
    sign_in_system_test(user:)
  end

  def when_i_visit_the_removed_schools_page
    visit removed_schools_path
  end

  def then_i_see_the_heading_with_count(count)
    expect(page).to have_content("We have removed #{count} schools from your account")
  end

  def and_i_see_removed_school(name, address)
    expect(page).to have_content(name)
    expect(page).to have_content(address)
  end

  def and_i_do_not_see_site(name)
    expect(page).not_to have_content(name)
  end

  def then_i_see_a_404_page
    expect(page).to have_content("Page not found").or have_http_status(:not_found)
  end
end
