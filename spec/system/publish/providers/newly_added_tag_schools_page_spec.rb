require "rails_helper"

RSpec.describe "Publish - Schools: 'Newly added' tag for register import sites", service: :publish, travel: 1.hour.before(find_closes(2025)) do
  include DfESignInUserHelper

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: 2026) }

  let(:provider) { create(:provider, provider_name: "Tag Provider", recruitment_cycle:) }

  let(:register_import_gias_school) { create(:gias_school, name: "Register Import School", urn: "111111") }
  let(:ui_added_gias_school) { create(:gias_school, name: "UI Added School", urn: "222222") }

  let!(:site_one) do
    create(
      :site,
      provider: provider,
      added_via: :register_import,
      location_name: "Register Import School",
      urn: register_import_gias_school.urn,
      address1: "1 Import Road",
    )
  end

  let!(:provider_school_one) do
    create(:provider_school, provider:, gias_school: register_import_gias_school, site_code: site_one.code, uuid: site_one.uuid)
  end

  let!(:site_two) do
    create(
      :site,
      provider: provider,
      added_via: :publish_interface,
      location_name: "UI Added School",
      urn: ui_added_gias_school.urn,
      address1: "2 Publish Street",
    )
  end

  let!(:provider_school_two) do
    create(:provider_school, provider:, gias_school: ui_added_gias_school, site_code: site_two.code, uuid: site_two.uuid)
  end

  let(:user) { create(:user, providers: [provider]) }

  scenario "shows the 'Newly added' tag for register import only" do
    sign_in_system_test(user:)
    when_i_visit_the_schools_page

    and_i_see_school_with_tag("Register Import School", "Newly added")
    and_i_see_school_without_tag("UI Added School", "Newly added")

    travel_to recruitment_cycle.rollover_end
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
