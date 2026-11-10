# frozen_string_literal: true

require "spec_helper"

RSpec.describe "API key management support" do
  include DfESignInUserHelper

  before do
    FeatureFlag.activate(:api_keys)
    sign_in_system_test(user: create(:user, :admin))
  end

  scenario "listing and searching active API keys" do
    given_there_are_api_keys
    when_i_visit_the_api_keys_page
    then_i_see_what_api_keys_are_for
    and_i_see_the_active_keys_newest_first

    when_i_search_for("apply@example")
    then_i_see_only_the_apply_key
  end

  scenario "creating an API key" do
    when_i_visit_the_api_keys_page
    and_i_click_create_api_key
    and_i_fill_in_the_key_details
    and_i_submit_the_form
    then_i_see_the_full_key_once
    and_the_key_shown_authenticates_as_the_new_key

    when_i_return_to_the_api_keys_page
    then_the_new_key_is_listed_without_its_secret
  end

  scenario "creating an API key without its details" do
    when_i_visit_the_api_keys_page
    and_i_click_create_api_key
    and_i_submit_the_form
    then_i_am_told_to_enter_a_name_and_email
  end

  scenario "revoking an API key" do
    given_there_are_api_keys
    when_i_visit_the_api_keys_page
    and_i_click_revoke_for_the_teacher_vacancies_key
    then_i_am_warned_that_integrations_will_stop_authenticating

    when_i_confirm_revoking_the_key
    then_i_see_the_key_was_revoked
    and_the_teacher_vacancies_key_is_no_longer_listed
    and_the_teacher_vacancies_key_is_revoked
  end

private

  attr_reader :vacancies_key, :apply_key

  def given_there_are_api_keys
    @vacancies_key = create(:api_key, name: "Teacher Vacancies", email: "vacancies@example.org", created_at: Time.zone.local(2026, 10, 2, 9))
    @apply_key = create(:api_key, name: "Apply", email: "apply@example.org", created_at: Time.zone.local(2026, 10, 20, 9))
    create(:api_key, name: "Retired integration", revoked_at: Time.zone.local(2026, 10, 21, 9))
  end

  def when_i_visit_the_api_keys_page
    visit support_root_path
    click_on "API keys"
  end

  def when_i_return_to_the_api_keys_page
    click_on "Back to API keys"
  end

  def when_i_search_for(query)
    fill_in "Search by name or email address", with: query
    click_on "Search"
  end

  def and_i_click_create_api_key
    click_on "Create API key"
  end

  def and_i_fill_in_the_key_details
    fill_in "Name", with: "Teacher Vacancies"
    fill_in "Email address", with: "vacancies@example.org"
  end

  def and_i_submit_the_form
    click_on "Create key"
  end

  def and_i_click_revoke_for_the_teacher_vacancies_key
    click_on "Revoke Teacher Vacancies"
  end

  def when_i_confirm_revoking_the_key
    click_on "Revoke key"
  end

  def then_i_see_what_api_keys_are_for
    expect(page).to have_content("An API key lets an integration authenticate with the Publish teacher training courses API")
  end

  def and_i_see_the_active_keys_newest_first
    expect(page).to have_table(rows: [
      apply_row,
      vacancies_row,
    ])
  end

  def then_i_see_only_the_apply_key
    expect(page).to have_table(rows: [apply_row])
  end

  def then_i_see_the_full_key_once
    expect(page).to have_content("API key created")
    expect(page).to have_content("This is the only time the key will be shown. Copy it now and store it securely.")
  end

  def and_the_key_shown_authenticates_as_the_new_key
    shown_key = page.text[/#{APIKey::SECRET_PREFIX}\h{64}/o]

    expect(APIKey.find_active_by_secret(shown_key)).to have_attributes(name: "Teacher Vacancies", email: "vacancies@example.org")
  end

  def then_the_new_key_is_listed_without_its_secret
    api_key = APIKey.sole

    expect(page).to have_table(rows: [
      ["Teacher Vacancies", "vacancies@example.org", api_key.prefix, api_key.created_at.to_fs(:govuk_date), "Revoke Teacher Vacancies"],
    ])
    expect(page).to have_no_content(/#{APIKey::SECRET_PREFIX}\h{64}/o)
  end

  def then_i_am_told_to_enter_a_name_and_email
    within(".govuk-error-summary") do
      expect(page).to have_content("There is a problem")
      expect(page.all("li").map(&:text)).to eq(["Enter a name for the API key", "Enter an email address"])
    end
    expect(APIKey.count).to eq(0)
  end

  def then_i_am_warned_that_integrations_will_stop_authenticating
    expect(page).to have_content("Are you sure you want to revoke Teacher Vacancies?")
    expect(page).to have_content("Any integration using this key will stop authenticating as soon as it is revoked. This cannot be undone.")
  end

  def then_i_see_the_key_was_revoked
    expect(page).to have_content("API key revoked")
  end

  def and_the_teacher_vacancies_key_is_no_longer_listed
    expect(page).to have_table(rows: [apply_row])
  end

  def and_the_teacher_vacancies_key_is_revoked
    expect(vacancies_key.reload.revoked_at).to be_present
  end

  def vacancies_row
    ["Teacher Vacancies", "vacancies@example.org", vacancies_key.prefix, "2 October 2026", "Revoke Teacher Vacancies"]
  end

  def apply_row
    ["Apply", "apply@example.org", apply_key.prefix, "20 October 2026", "Revoke Apply"]
  end
end
