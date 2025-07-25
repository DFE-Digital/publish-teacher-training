# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Accredited partnership flow" do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_are_accredited_providers_in_the_database
    and_i_visit_the_index_page
  end

  scenario "i can view the accredited partnerships tab when there are none" do
    then_i_see_the_correct_text_for_no_accredited_providers
  end

  scenario "i can view accredited partnerships on the index page" do
    and_my_provider_has_accrediting_providers
    and_i_click_on_the_accredited_provider_tab
    then_i_see_the_accredited_provider_name_displayed

    when_i_click_the_accredited_provider_link
    then_i_am_on_the_accredited_providers_page
  end

  scenario "i can create a new provider partnership" do
    when_i_click_add_accredited_provider
    and_i_search_with_an_invalid_query
    then_i_see_an_error_message("Enter a provider name")

    when_i_search_for_an_accredited_provider_with_a_valid_query
    then_i_see_the_provider_i_searched_for

    when_i_continue_without_selecting_an_accredited_provider
    and_i_see_an_error_message("Select an accredited provider")
    then_i_still_see_the_provider_i_searched_for

    when_i_select_the_provider

    when_i_confirm_the_changes
    then_i_return_to_the_index_page
    and_the_accredited_provider_is_saved_to_the_database
    and_i_see_the_create_success_message
    and_i_see_the_accredited_partnership
  end

  scenario "i cannot delete accredited partnerships attached to a course" do
    and_my_provider_has_accrediting_providers
    and_i_click_on_the_accredited_provider_tab
    and_i_click_remove
    then_i_see_the_cannot_remove_text
  end

  scenario "i can delete accredited partnerships not attached to a course" do
    and_i_click_on_the_accredited_provider_tab
    and_i_click_add_accredited_provider
    and_i_search_for_an_accredited_provider_with_a_valid_query
    and_i_select_the_provider
    and_i_confirm_the_changes
    and_i_click_remove
    and_i_click_remove_ap
    then_i_return_to_the_index_page
    and_i_see_the_remove_success_message
  end

private

  def and_i_see_the_remove_success_message
    expect(page).to have_content("Accredited provider removed")
  end

  def and_i_see_the_create_success_message
    expect(page).to have_content("Accredited provider added")
  end

  def and_i_click_remove_ap
    click_link_or_button "Remove accredited provider"
  end

  def and_i_confirm_the_changes
    click_link_or_button "Add accredited provider"
  end
  alias_method :when_i_confirm_the_changes, :and_i_confirm_the_changes

  def and_i_select_the_provider
    choose @accredited_provider.provider_name
    click_link_or_button "Continue"
  end
  alias_method :when_i_select_the_provider, :and_i_select_the_provider

  def form_title
    "Enter a provider name, UKPRN or postcode"
  end

  def and_i_search_with_an_invalid_query
    fill_in form_title, with: ""
    click_link_or_button "Continue"
  end

  def when_i_continue_without_selecting_an_accredited_provider
    click_link_or_button "Continue"
  end

  def and_i_search_for_an_accredited_provider_with_a_valid_query
    fill_in form_title, with: @accredited_provider.provider_name
    click_link_or_button "Continue"
  end
  alias_method :when_i_search_for_an_accredited_provider_with_a_valid_query, :and_i_search_for_an_accredited_provider_with_a_valid_query

  def then_i_see_the_provider_i_searched_for
    expect(page).to have_content(@accredited_provider.provider_name)
    expect(page).to have_no_content(@accredited_provider_two.provider_name)
    expect(page).to have_no_content(@accredited_provider_three.provider_name)
  end
  alias_method :then_i_still_see_the_provider_i_searched_for, :then_i_see_the_provider_i_searched_for

  def and_i_click_add_accredited_provider
    click_link_or_button "Add accredited provider"
  end
  alias_method :when_i_click_add_accredited_provider, :and_i_click_add_accredited_provider

  def and_i_click_remove
    click_link_or_button "Remove"
  end

  def then_i_see_the_cannot_remove_text
    expect(page).to have_css("h1", text: "You cannot remove this accredited provider")
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def and_there_are_accredited_providers_in_the_database
    @provider = create(:provider, :lead_school)
    @accredited_provider = create(:provider, :accredited_provider, provider_name: "UCL", users: [create(:user)])
    @accredited_provider_two = create(:provider, :accredited_provider, provider_name: "Accredited provider two")
    @accredited_provider_three = create(:provider, :accredited_provider, provider_name: "Accredited provider three")
  end

  def then_i_return_to_the_index_page
    expect(page).to have_current_path(support_recruitment_cycle_provider_accredited_partnerships_path(
                                        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
                                        provider_id: @provider.id,
                                      ))
  end

  def and_i_visit_the_index_page
    visit support_recruitment_cycle_provider_accredited_partnerships_path(
      recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      provider_id: @provider.id,
    )
  end

  def and_i_click_change
    click_link_or_button("Change")
  end

  def when_i_click_the_back_link
    click_link_or_button "Back"
  end

  def and_i_see_an_error_message(error_message = form_title)
    expect(page).to have_content(error_message)
  end
  alias_method :then_i_see_an_error_message, :and_i_see_an_error_message

  def then_i_see_the_correct_text_for_no_accredited_providers
    expect(page).to have_text("There are no accredited providers for #{@provider.provider_name}")
  end

  def and_i_click_on_the_accredited_provider_tab
    click_link_or_button "Accredited providers"
  end

  def and_my_provider_has_accrediting_providers
    @course = build(:course, accrediting_provider: build(:provider, :accredited_provider, provider_name: "Accrediting provider name"))

    @provider.accredited_partnerships.create(accredited_provider: @course.accrediting_provider)
    @provider.courses << @course
  end

  def and_i_see_the_accredited_partnership
    expect(page).to have_content(@accredited_provider.provider_name)
  end

  def and_the_accredited_provider_is_saved_to_the_database
    @provider.reload
    expect(@provider.accredited_partners.count).to eq(1)
    expect(@provider.accredited_partners.first.id).to eq(@accredited_provider.id)
  end

  def then_i_see_the_accredited_provider_name_displayed
    expect(page).to have_css(
      "h2.govuk-summary-card__title a.govuk-link",
      text: "Accrediting provider name",
    )
  end

  def when_i_click_the_accredited_provider_link
    page.click_link_or_button @course.accrediting_provider.provider_name
  end

  def then_i_am_on_the_accredited_providers_page
    expect(page).to have_current_path(support_recruitment_cycle_provider_path(@course.accrediting_provider.recruitment_cycle_year, @course.accrediting_provider))
  end
end
