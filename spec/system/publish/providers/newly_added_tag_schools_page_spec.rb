require "rails_helper"

RSpec.describe "Publish - Schools: 'Newly added' tag for register import sites", service: :publish, type: :system do
  include DfESignInUserHelper

  let(:frozen_time) { Time.zone.local(2025, 6, 1, 12, 0, 0) }
  let!(:recruitment_cycle) do
    create(:recruitment_cycle, year: 2026, application_start_date: frozen_time + 2.months)
  end
  let(:provider) { create(:provider, provider_name: "Tag Provider", recruitment_cycle:) }

  let!(:site_one) do
    create(
      :site,
      provider: provider,
      added_via: :register_import,
      location_name: "Register Import School",
      address1: "1 Import Road",
    )
  end

  let!(:site_two) do
    create(
      :site,
      provider: provider,
      added_via: :publish_interface,
      location_name: "UI Added School",
      address1: "2 Publish Street",
    )
  end

  let(:user) { create(:user, providers: [provider]) }

  before do
    travel_to frozen_time
    sign_in_system_test(user:)
  end

  after { travel_back }

  scenario "shows the 'Newly added' tag for register import only" do
    when_i_visit_the_schools_page

    and_i_see_school_with_tag("Register Import School", "Newly added")
    and_i_see_school_without_tag("UI Added School", "Newly added")

    travel_to recruitment_cycle.application_start_date + 1.day
    sign_in_system_test(user:)
    when_i_visit_the_schools_page
    and_i_see_school_without_tag("Register Import School", "Newly added")
    and_i_see_school_without_tag("UI Added School", "Newly added")
  end

private

  def when_i_visit_the_schools_page
    visit publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year)
  end

  def and_i_see_school_with_tag(school_name, tag_text)
    school_row = find_school_row_by_name(school_name)
    expect(school_row).to have_content(tag_text), "Expected '#{tag_text}' tag for '#{school_name}', but did not find it. Row text: #{school_row.text}"
  end

  def and_i_see_school_without_tag(school_name, tag_text)
    school_row = find_school_row_by_name(school_name)
    expect(school_row).not_to have_content(tag_text), "Expected NOT to find '#{tag_text}' tag for '#{school_name}', but tag was present. Row text: #{school_row.text}"
  end

  def find_school_row_by_name(name)
    page.find(:xpath, %{//*[contains(text(),"#{name}")]/ancestor::*[self::tr or self::div[contains(@class,"row")]][1]})
  end
end
