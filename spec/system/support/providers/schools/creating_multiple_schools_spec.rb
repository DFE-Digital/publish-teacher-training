# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Multiple schools" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_some_gias_schools_exist
  end

  scenario "submitting an empty form" do
    when_i_visit_a_provider_schools_page
    then_i_click_add_multiple_schools

    given_i_submit_an_empty_form
    then_i_should_see_the_validation_error_message
  end

  scenario "when the urns are comma separated and newline separated" do
    when_i_visit_the_multiple_schools_new_page
    and_i_fill_in_the_urns_with_a_mixture_of_new_lines_and_comma
    and_i_click_continue

    and_i_am_redirected_to_the_multiple_school_check_page

    when_i_click_add_schools
    then_i_am_redirected_to_the_school_index
    and_i_see_that_all_schools_are_created
    and_i_see_the_success_message
  end

  scenario "when there are over 50 urns" do
    when_i_visit_the_multiple_schools_new_page
    and_i_enter_51_urns
    when_i_submit_the_form
    then_i_see_an_error_message_for_too_many_urns
  end

  scenario "when one of the URNs is already added" do
    when_i_visit_the_multiple_schools_new_page
    and_i_have_one_existing_school
    and_i_enter_only_an_existing_urn
    when_i_submit_the_form
    then_i_see_the_urn_appear_under_the_existing_urn_warning
  end

  scenario "when one of the URNs could not be found" do
    when_i_visit_the_multiple_schools_new_page
    and_i_enter_only_an_unfound_urn
    when_i_submit_the_form
    then_i_see_the_urn_appear_under_the_unfound_urn_warning
  end

  scenario "clicking back" do
    when_i_visit_the_multiple_schools_new_page
    and_i_click_back
    then_i_am_on_the_schools_index_page

    when_i_visit_the_multiple_schools_new_page
    and_i_enter_only_an_existing_urn
    and_i_submit_the_form
    and_i_am_redirected_to_the_multiple_school_check_page
    and_i_click_back
    then_i_am_on_the_enter_urns_page
    and_the_textarea_maintains_the_urns

    when_i_click_back
    then_i_am_on_the_schools_index_page

    when_i_click_add_multiple_schools
    then_i_see_the_textarea_is_empty

    when_i_click_cancel
    then_i_am_on_the_schools_index_page

    when_i_click_add_multiple_schools
    then_i_see_the_textarea_is_empty
  end

  scenario "removing schools" do
    when_i_visit_the_multiple_schools_new_page
    and_i_enter_two_urns
    and_i_click_continue
    then_i_see_two_schools_with_remove_links

    when_i_click_remove_school
    then_there_is_only_one_school_on_the_page
    and_i_see_a_success_message

    when_i_click_remove_school
    then_there_is_no_school_on_the_page
    and_i_see_a_success_message

    when_there_are_no_schools_on_the_page
    then_the_submit_button_is_gone
    and_a_link_to_enter_new_urns_appears

    when_i_click_enter_new_urns
    then_i_am_on_the_enter_urns_page
  end

  def and_some_gias_schools_exist
    @gias_schools = create_list(:gias_school, 3)
  end

  def and_i_fill_in_the_urns_with_a_mixture_of_new_lines_and_comma
    urns = @gias_schools.map(&:urn)
    input = "  #{urns[0]},#{urns[1]}\n\n#{urns[2]}"
    fill_in "Enter URNs", with: input
  end

  def then_i_am_redirected_to_the_school_index
    expect(page).to have_current_path(support_recruitment_cycle_provider_schools_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id))
  end

  def and_i_see_that_all_schools_are_created
    @gias_schools.each do |school|
      expect(page).to have_css(".school-row", text: /#{school.name}.*#{school.urn}/)
    end
  end

  def and_i_enter_51_urns
    input = "100000"
    51.times do |n|
      input += ",#{n + 100_000}"
    end
    fill_in "Enter URNs", with: input
  end

  def when_i_submit_the_form
    click_link_or_button "Continue"
  end

  def then_i_see_an_error_message_for_too_many_urns
    within(".govuk-error-summary") do
      expect(page).to have_content("You have entered too many URNs. You can enter a maximum of 50 URNs.")
    end
  end

  def and_i_enter_only_nonexisting_urns
    input = "invalid_urn,another"
    fill_in "Enter URNs", with: input
  end

  def then_the_submit_button_is_gone
    expect(page).to have_no_content("Add schools")
  end

  def and_a_link_to_enter_new_urns_appears
    expect(page).to have_link("Enter new URNs")
  end

  def when_i_click_enter_new_urns
    page.click_link_or_button("Enter new URNs")
  end

  def when_there_are_no_schools_on_the_page
    expect(page).to have_no_link("Remove school")
  end

  def then_i_see_two_schools_with_remove_links
    expect(page).to have_link("Remove school", count: 2)
  end

  def when_i_click_remove_school
    page.find(:link, "Remove school", match: :first).click
  end

  def then_there_is_only_one_school_on_the_page
    expect(page).to have_link("Remove school", count: 1)
  end

  def then_there_is_no_school_on_the_page
    expect(page).to have_no_link("Remove school")
  end

  def and_i_enter_two_urns
    fill_in "Enter URNs", with: @gias_schools.take(2).map(&:urn).join("\n")
  end

  def and_i_see_a_success_message
    within(".govuk-notification-banner") do
      expect(page).to have_content("Success\nSchool removed")
    end
  end

  scenario "remove all schools" do
    when_i_visit_the_multiple_schools_new_page
  end

  scenario "cancel from multiple schools new page" do
    when_i_visit_the_multiple_schools_new_page

    when_i_click_cancel
    then_i_should_be_on_the_provider_schools_page
  end

  def and_i_see_the_success_message
    expect(page).to have_text("3 schools added")
  end

  def and_i_am_redirected_to_the_multiple_school_check_page
    expect(page).to have_current_path support_recruitment_cycle_provider_schools_multiple_check_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
    expect(page).to have_text "Check your answers"
  end

  def when_i_visit_the_multiple_schools_new_page
    visit new_support_recruitment_cycle_provider_schools_multiple_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def when_i_visit_a_provider_schools_page
    visit support_recruitment_cycle_provider_schools_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def and_i_have_one_existing_school
    provider.sites.school.create(@gias_schools.first.school_attributes)
  end

  def and_i_enter_only_an_existing_urn
    input = @gias_schools.first.urn
    fill_in "Enter URNs", with: input
  end

  def then_i_see_the_urn_appear_under_the_existing_urn_warning
    within(page.find("strong", text: "Schools with these URNs have already been added")) do
      expect(page).to have_content(@gias_schools.first.urn)
    end
  end

  def and_i_enter_only_an_unfound_urn
    input = "unfound"
    fill_in "Enter URNs", with: input
  end

  def then_i_see_the_urn_appear_under_the_unfound_urn_warning
    within(page.find("strong", text: "Some URNs could not be found")) do
      expect(page).to have_content("unfound")
    end
  end

  def and_the_textarea_maintains_the_urns
    field = page.find_field("Enter URNs")
    expect(field).to have_content(@gias_schools.first.urn)
  end

  def then_i_see_the_textarea_is_empty
    field = page.find_field("Enter URNs")
    expect(field).to have_no_content(@gias_schools.first.urn)
  end

  def provider
    @provider ||= create(:provider, sites: [build(:site)])
  end

  def then_i_click_add_multiple_schools
    click_link_or_button "Add multiple schools"
  end

  def given_i_submit_an_empty_form
    click_link_or_button "Continue"
  end

  def when_i_click_back
    click_link_or_button "Back"
  end

  def when_i_click_cancel
    click_link_or_button "Cancel"
  end

  def when_i_click_add_schools
    click_link_or_button "Add schools"
  end

  def then_i_should_see_the_validation_error_message
    within(".govuk-error-summary") do
      expect(page).to have_content("There is a problem\nEnter URNs")
    end
  end

  def when_i_am_redirected_to_the_schools_page
    expect(page).to have_current_path support_recruitment_cycle_provider_schools_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def and_i_am_on_the_enter_urns_page
    expect(page).to have_current_path new_support_recruitment_cycle_provider_schools_multiple_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  alias_method :and_i_click_add_schools, :when_i_click_add_schools
  alias_method :and_i_click_back, :when_i_click_back
  alias_method :then_i_should_be_on_the_provider_schools_page, :when_i_am_redirected_to_the_schools_page
  alias_method :and_i_should_be_on_the_provider_schools_page, :when_i_am_redirected_to_the_schools_page
  alias_method :then_i_am_on_the_schools_index_page, :then_i_am_redirected_to_the_school_index
  alias_method :and_i_click_continue, :given_i_submit_an_empty_form
  alias_method :when_i_click_continue, :given_i_submit_an_empty_form
  alias_method :and_i_submit_the_form, :given_i_submit_an_empty_form
  alias_method :when_i_click_add_multiple_schools, :then_i_click_add_multiple_schools
  alias_method :then_i_am_on_the_enter_urns_page, :and_i_am_on_the_enter_urns_page
  alias_method :and_i_click_add_multiple_schools, :then_i_click_add_multiple_schools
end
