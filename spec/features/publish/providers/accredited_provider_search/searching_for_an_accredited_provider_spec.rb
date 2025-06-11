# frozen_string_literal: true

require "rails_helper"

feature "Searching for an accredited provider" do
  before do
    given_i_am_a_lead_school_provider_user
    and_there_are_accredited_providers_in_the_database
  end

  scenario "i can search for an accredited provider by query" do
    when_i_visit_the_accredited_provider_search_page
    and_i_search_with_an_invalid_query
    then_i_see_an_error_message

    when_i_search_for_an_accredited_provider_with_a_valid_query
    then_i_see_the_provider_i_searched_for

    when_i_continue_without_selecting_an_accredited_provider
    then_i_see_an_error_message("Select an accredited provider")
    and_i_still_see_the_provider_i_searched_for

    when_i_select_the_provider

    and_i_confirm_the_changes
    then_i_am_taken_to_the_index_page
    and_i_see_a_success_message
    and_i_see_the_accredited_providers
  end

  scenario "back links behaviour" do
    when_i_visit_the_accredited_provider_search_page
    when_i_search_for_an_accredited_provider_with_a_valid_query
    when_i_select_the_provider
    when_i_click_the_back_link
    then_i_am_taken_to_the_accredited_provider_search_page

    when_i_am_on_the_confirm_page
    and_i_click_the_change_link_for("accredited provider name")
    then_i_am_taken_to_the_accredited_provider_search_page_with_confirmation
    when_i_click_the_back_link
    then_i_am_taken_back_to_the_confirm_page

    when_i_am_on_the_confirm_page
  end

private

  def given_i_am_a_lead_school_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
    @provider = @current_user.providers.first
  end

  def and_there_are_accredited_providers_in_the_database
    @accredited_provider = create(:provider, :accredited_provider, provider_name: "UCL", users: [create(:user)])
    @accredited_provider_two = create(:provider, :accredited_provider, provider_name: "Accredited provider two")
    @accredited_provider_three = create(:provider, :accredited_provider, provider_name: "Accredited provider three")
  end

  def when_i_visit_the_accredited_provider_search_page
    visit search_publish_provider_recruitment_cycle_accredited_providers_path(
      recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      provider_code: provider.provider_code,
    )
  end

  def when_i_search_for_an_accredited_provider_with_a_valid_query
    fill_in form_title, with: @accredited_provider.provider_name
    click_continue
  end

  def then_i_see_the_provider_i_searched_for
    expect(page).to have_content(@accredited_provider.provider_name)
    expect(page).to have_no_content(@accredited_provider_two.provider_name)
    expect(page).to have_no_content(@accredited_provider_three.provider_name)
  end

  def when_i_select_the_provider
    choose @accredited_provider.provider_name
    click_continue
  end

  def then_i_am_taken_to_the_index_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_accredited_partnerships_path(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        provider_code: provider.provider_code,
      ),
    )
  end

  def and_i_search_with_an_invalid_query
    fill_in form_title, with: ""
    click_continue
  end

  def then_i_see_an_error_message(error_message = form_title)
    expect(page).to have_content(error_message)
  end

  def when_i_continue_without_selecting_an_accredited_provider
    click_continue
  end

  def and_i_still_see_the_provider_i_searched_for
    expect(page).to have_content(@accredited_provider.provider_name)
    expect(page).to have_no_content(@accredited_provider_two.provider_name)
    expect(page).to have_no_content(@accredited_provider_three.provider_name)
  end

  def and_i_confirm_the_changes
    expect {
      click_link_or_button "Add accredited provider"
    }.to have_enqueued_email(Users::OrganisationMailer, :added_as_an_organisation_to_training_partner)
  end

  def and_i_see_a_success_message
    expect(page).to have_content("Accredited provider added")
  end

  def and_i_see_the_accredited_providers
    expect(page).to have_css(".govuk-table__cell", count: 1)
    expect(page).to have_content(@accredited_provider.provider_name)
  end

  def click_continue
    click_link_or_button "Continue"
  end

  def when_i_am_on_the_confirm_page
    when_i_visit_the_accredited_provider_search_page
    when_i_search_for_an_accredited_provider_with_a_valid_query
    when_i_select_the_provider
  end

  def and_i_click_the_change_link_for(field)
    within ".govuk-summary-list" do
      click_link_or_button "Change #{field}"
    end
  end

  def then_i_am_taken_to_the_accredited_provider_search_page
    expect(page).to have_current_path(
      search_publish_provider_recruitment_cycle_accredited_providers_path(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        provider_code: provider.provider_code,
      ),
    )
  end

  def then_i_am_taken_to_the_accredited_provider_search_page_with_confirmation
    expect(page).to have_current_path(
      search_publish_provider_recruitment_cycle_accredited_providers_path(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        provider_code: provider.provider_code,
        accredited_provider_id: @accredited_provider.id,
        goto_confirmation: true,
      ),
    )
  end

  def then_i_am_taken_to_the_accredited_provider_description_page
    expect(page).to have_current_path(
      new_publish_provider_recruitment_cycle_accredited_partnership_path(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        provider_code: provider.provider_code,
        goto_confirmation: true,
      ),
    )
  end

  def when_i_click_the_back_link
    click_link_or_button "Back"
  end

  def then_i_am_taken_back_to_the_confirm_page
    expect(page).to have_current_path(
      check_publish_provider_recruitment_cycle_accredited_partnerships_path(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        provider_code: provider.provider_code,
        accredited_provider_id: @accredited_provider.id,
      ),
    )
  end

  def provider
    @provider ||= create(:provider)
  end

  def form_title
    "Enter a provider name, UKPRN or postcode"
  end

  alias_method :and_i_continue_without_entering_a_description, :click_continue
end
