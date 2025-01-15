# frozen_string_literal: true

require 'rails_helper'

feature 'Searching for an accredited provider' do
  before do
    allow(Settings.features).to receive(:provider_partnerships).and_return(true)
    given_i_am_authenticated_as_an_admin_user
    and_there_are_accredited_providers_in_the_database
  end

  scenario 'i can search for an accredited provider by query' do
    when_i_visit_the_accredited_provider_search_page
    and_i_search_with_an_invalid_query
    then_i_should_see_an_error_message

    when_i_search_for_an_accredited_provider_with_a_valid_query
    then_i_see_the_provider_i_searched_for

    when_i_continue_without_selecting_an_accredited_provider
    then_i_should_see_an_error_message('Select an accredited provider')
    and_i_should_still_see_the_provider_i_searched_for

    when_i_select_the_provider
    and_i_continue_without_entering_a_description
    then_i_should_see_an_error_message('Enter details about the accredited partnership')

    when_i_enter_a_description
    and_i_confirm_the_changes
    then_i_should_be_taken_to_the_index_page
    and_i_should_see_a_success_message
    and_i_should_see_the_accredited_providers
  end

  scenario 'back links behaviour' do
    when_i_am_on_the_confirm_page
    and_i_click_the_change_link_for('accredited partner name')
    then_i_should_be_taken_to_the_accredited_provider_search_page
    when_i_click_the_back_link
    then_i_should_be_taken_back_to_the_confirm_page

    when_i_am_on_the_confirm_page
    and_i_click_the_change_link_for('accredited partner description')
    then_i_should_be_taken_to_the_accredited_provider_description_page
    when_i_click_the_back_link
    then_i_should_be_taken_back_to_the_confirm_page
  end

  private

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def and_there_are_accredited_providers_in_the_database
    @accredited_provider = create(:provider, :accredited_provider, provider_name: 'UCL', users: [create(:user)])
    @accredited_provider_two = create(:provider, :accredited_provider, provider_name: 'Accredited provider two')
    @accredited_provider_three = create(:provider, :accredited_provider, provider_name: 'Accredited provider three')
  end

  def when_i_visit_the_accredited_provider_search_page
    visit search_support_recruitment_cycle_provider_accredited_providers_path(
      recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      provider_id: provider.id
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

  def then_i_should_be_taken_to_the_index_page
    expect(page).to have_current_path(
      support_recruitment_cycle_provider_accredited_partners_path(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        provider_id: provider.id
      )
    )
  end

  def and_i_search_with_an_invalid_query
    fill_in form_title, with: ''
    click_continue
  end

  def then_i_should_see_an_error_message(error_message = form_title)
    expect(page).to have_content(error_message)
  end

  def when_i_continue_without_selecting_an_accredited_provider
    click_continue
  end

  def and_i_should_still_see_the_provider_i_searched_for
    expect(page).to have_content(@accredited_provider.provider_name)
    expect(page).to have_no_content(@accredited_provider_two.provider_name)
    expect(page).to have_no_content(@accredited_provider_three.provider_name)
  end

  def when_i_enter_a_description
    fill_in 'About the accredited partner', with: 'This is a description'
    click_continue
  end

  def and_i_confirm_the_changes
    expect do
      click_link_or_button 'Add accredited partner'
    end.to have_enqueued_email(Users::OrganisationMailer, :added_as_an_organisation_to_training_partner)
  end

  def and_i_should_see_a_success_message
    expect(page).to have_content('Accredited partner added')
  end

  def and_i_should_see_the_accredited_providers
    expect(page).to have_css('.govuk-summary-card', count: 1)
    expect(page).to have_content(@accredited_provider.provider_name)
  end

  def click_continue
    click_link_or_button 'Continue'
  end

  def when_i_am_on_the_confirm_page
    when_i_visit_the_accredited_provider_search_page
    when_i_search_for_an_accredited_provider_with_a_valid_query
    when_i_select_the_provider
    when_i_enter_a_description
  end

  def and_i_click_the_change_link_for(field)
    within '.govuk-summary-list' do
      click_link_or_button "Change #{field}"
    end
  end

  def then_i_should_be_taken_to_the_accredited_provider_search_page
    expect(page).to have_current_path(
      search_support_recruitment_cycle_provider_accredited_providers_path(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        provider_id: provider.id,
        goto_confirmation: true
      )
    )
  end

  def then_i_should_be_taken_to_the_accredited_provider_description_page
    expect(page).to have_current_path(
      new_support_recruitment_cycle_provider_accredited_partner_path(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        provider_id: provider.id,
        goto_confirmation: true
      )
    )
  end

  def when_i_click_the_back_link
    click_link_or_button 'Back'
  end

  def then_i_should_be_taken_back_to_the_confirm_page
    expect(page).to have_current_path(
      check_support_recruitment_cycle_provider_accredited_partners_path(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        provider_id: provider.id
      )
    )
  end

  def provider
    @provider ||= create(:provider)
  end

  def form_title
    'Enter a provider name, UKPRN or postcode'
  end

  alias_method :and_i_continue_without_entering_a_description, :click_continue
end
