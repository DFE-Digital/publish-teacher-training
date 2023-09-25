# frozen_string_literal: true

require 'rails_helper'

feature 'Accredited provider flow', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_are_accredited_providers_in_the_database
    and_i_visit_the_index_page
  end

  scenario 'i can view the accredited providers tab when there are none' do
    then_i_see_the_correct_text_for_no_accredited_providers
  end

  scenario 'i can view accredited providers on the index page' do
    and_my_provider_has_accrediting_providers
    and_i_click_on_the_accredited_provider_tab
    then_i_should_see_the_accredited_provider_name_displayed
  end

  scenario 'i can edit accredited providers on the index page' do
    and_my_provider_has_accrediting_providers
    and_i_click_on_the_accredited_provider_tab
    and_i_click_change

    when_i_click_the_back_link
    then_i_return_to_the_index_page
    and_i_click_change

    when_i_input_updated_description
    then_i_should_see_the_updated_description
    and_i_see_the_success_message
  end

  scenario 'i cannot delete accredited providers attached to a course' do
    and_my_provider_has_accrediting_providers
    and_i_click_on_the_accredited_provider_tab
    and_i_click_remove
    then_i_should_see_the_cannot_remove_text
  end

  scenario 'i can delete accredited providers not attached to a course' do
    and_i_click_on_the_accredited_provider_tab
    and_i_click_add_accredited_provider
    and_i_search_for_an_accredited_provider_with_a_valid_query
    and_i_select_the_provider
    when_i_input_new_information
    and_i_confirm_the_changes
    and_i_click_remove
    and_i_click_remove_ap
    then_i_return_to_the_index_page
    and_i_see_the_remove_success_message
  end

  private

  def and_i_see_the_remove_success_message
    expect(page).to have_content('Accredited provider removed')
  end

  def and_i_see_the_remove_success_message; end

  def and_i_click_remove_ap
    click_button 'Remove accredited provider'
  end

  def and_i_confirm_the_changes
    click_button 'Add accredited provider'
  end

  def when_i_input_new_information
    fill_in 'About the accredited provider', with: 'New AP description'
    click_button 'Continue'
  end

  def and_i_select_the_provider
    choose @accredited_provider.provider_name
    click_button 'Continue'
  end

  def form_title
    'Enter a provider name, UKPRN or postcode'
  end

  def and_i_search_for_an_accredited_provider_with_a_valid_query
    fill_in form_title, with: @accredited_provider.provider_name
    click_button 'Continue'
  end

  def and_i_click_add_accredited_provider
    click_link 'Add accredited provider'
  end

  def and_i_click_remove
    click_link 'Remove'
  end

  def then_i_should_see_the_cannot_remove_text
    expect(page).to have_css('h1', text: 'You cannot remove this accredited provider')
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def and_there_are_accredited_providers_in_the_database
    @provider = create(:provider, :lead_school)
    @accredited_provider = create(:provider, :accredited_provider, provider_name: 'UCL', users: [create(:user)])
    @accredited_provider_two = create(:provider, :accredited_provider, provider_name: 'Accredited provider two')
    @accredited_provider_three = create(:provider, :accredited_provider, provider_name: 'Accredited provider three')
  end

  def then_i_return_to_the_index_page
    expect(page).to have_current_path(support_recruitment_cycle_provider_accredited_providers_path(
                                        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
                                        provider_id: @provider.id
                                      ))
  end

  def and_i_visit_the_index_page
    visit support_recruitment_cycle_provider_accredited_providers_path(
      recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      provider_id: @provider.id
    )
  end

  def and_i_click_change
    click_link('Change')
  end

  def when_i_click_the_back_link
    click_link 'Back'
  end

  def and_i_see_the_success_message
    expect(page).to have_content('About the accredited provider updated')
  end

  def then_i_should_see_the_updated_description
    expect(page).to have_text('update the AP description')
  end

  def when_i_input_updated_description
    fill_in 'About the accredited provider', with: 'update the AP description'
    click_button 'Update description'
  end

  def then_i_see_the_correct_text_for_no_accredited_providers
    expect(page).to have_text("There are no accredited providers for #{@provider.provider_name}")
  end

  def and_i_click_on_the_accredited_provider_tab
    click_link 'Accredited provider'
  end

  def and_my_provider_has_accrediting_providers
    course = build(:course, accrediting_provider: build(:provider, :accredited_provider, provider_name: 'Accrediting provider name'))

    @provider.courses << course
    @provider.update(
      accrediting_provider_enrichments: [{
        'UcasProviderCode' => course.accrediting_provider.provider_code
      }]
    )
  end

  def then_i_should_see_the_accredited_provider_name_displayed
    expect(page).to have_css('h2', text: 'Accrediting provider name')
  end
end
