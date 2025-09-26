require "rails_helper"

RSpec.describe "Publish - Providers - Added Schools page", service: :publish, type: :system do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let!(:site_one) do
    create(
      :site,
      provider:,
      location_name: "Alpha School",
      address1: "Alpha Street",
      address2: "Pine Oaks",
      address3: "",
      address4: "",
      town: "Alphatown",
      postcode: "AA1 2AA",
      added_via: :register_import,
    )
  end
  let!(:site_two) do
    create(
      :site,
      provider:,
      location_name: "Beta Academy",
      address1: "123 Academy Road",
      address2: "Summer Heights",
      address3: "",
      address4: "",
      town: "Betatown",
      postcode: "BB1 3BB",
      added_via: :register_import,
    )
  end
  let!(:site_three) do
    create(
      :site,
      provider:,
      added_via: :publish_interface,
      location_name: "Not Shown",
    )
  end
  let(:user) { create(:user, providers: [provider]) }
  let(:added_schools_path) do
    added_schools_publish_provider_recruitment_cycle_schools_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle.year,
    )
  end

  context "when the 2026 cycle has not yet started", travel: 1.hour.before(find_closes(2025)) do
    let!(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: 2026) }

    before do
      and_provider_is_linked_to_recruitment_cycle
      and_user_is_signed_in
    end

    scenario "shows the added schools" do
      when_i_visit_the_added_schools_page
      then_i_see_the_heading_with_count(2)
      and_i_see_the_register_trainee_teachers_link
      and_i_see_added_school "Alpha School", "Alpha Street, Pine Oaks, Alphatown, AA1 2AA"
      and_i_see_added_school "Beta Academy", "123 Academy Road, Summer Heights, Betatown, BB1 3BB"
      and_i_do_not_see_site "Not Shown"
    end
  end

  context "when the 2026 cycle has started" do
    let!(:recruitment_cycle) do
      find_or_create(:recruitment_cycle, year: 2026, application_start_date: 2.months.after(find_opens(2026)))
    end

    before do
      and_provider_is_linked_to_recruitment_cycle
      and_user_is_signed_in
    end

    scenario "returns a 404 page", travel: mid_cycle(2026) do
      when_i_visit_the_added_schools_page
      then_i_see_a_404_page
    end
  end

private

  def and_provider_is_linked_to_recruitment_cycle
    provider.update!(recruitment_cycle:)
  end

  def and_user_is_signed_in
    sign_in_system_test(user:)
  end

  def when_i_visit_the_added_schools_page
    visit added_schools_path
  end

  def then_i_see_the_heading_with_count(count)
    expect(page).to have_content("We have added #{count} schools to your account")
  end

  def and_i_see_the_register_trainee_teachers_link
    expect(page).to have_link(
      "Register trainee teachers",
      href: "https://www.register-trainee-teachers.service.gov.uk/",
    )
  end

  def and_i_see_added_school(name, address)
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
