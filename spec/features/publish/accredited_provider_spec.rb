# frozen_string_literal: true

require 'rails_helper'

feature 'Accredited provider flow', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_a_lead_school_provider_user
    and_the_accredited_provider_search_feature_is_on
    and_i_visit_the_root_path
    when_i_click_on_the_accredited_provider_tab
  end

  scenario 'i can view the accredited providers tab when there are none' do
    then_i_see_the_correct_text_for_no_accredited_providers
  end

  scenario 'i can view accredited providers on the index page' do
    and_my_provider_has_accrediting_providers
    and_i_click_on_the_accredited_provider_tab
    then_i_should_see_the_accredited_provider_name_displayed
  end

  scenario 'i can search for an accredited provider when they are searchable' do
    given_there_are_accredited_providers_in_the_database
    when_i_click_add_accredited_provider
    and_i_search_with_an_invalid_query
    then_i_should_see_an_error_message

    when_i_search_for_an_accredited_provider_with_a_valid_query
    then_i_see_the_provider_i_searched_for

    when_i_continue_without_selecting_an_accredited_provider
    and_i_should_see_an_error_message('Select an accredited provider')
    then_i_should_still_see_the_provider_i_searched_for

    when_i_select_the_provider
    and_i_continue_without_entering_a_description
    then_i_should_see_an_error_message('Enter details about the accredited provider')

    when_i_input_some_information
    then_i_should_see_the_information_i_added

    when_i_confirm_the_changes
    then_i_should_be_taken_to_the_index_page
    and_i_should_see_a_success_message
  end

  scenario 'back links behaviour' do
    given_i_am_on_the_confirm_page
    when_i_click_the_change_link_for('accredited provider name')
    then_i_should_be_taken_to_the_accredited_provider_search_page

    when_i_click_the_back_link
    then_i_should_be_taken_back_to_the_confirm_page

    when_i_click_the_change_link_for('accredited provider description')
    then_i_should_be_taken_to_the_accredited_provider_description_page

    when_i_click_the_back_link
    then_i_should_be_taken_back_to_the_confirm_page
  end

  private

  def then_i_should_be_taken_to_the_accredited_provider_description_page
    expect(page).to have_current_path(new_publish_provider_recruitment_cycle_accredited_provider_path(@provider.provider_code, @provider.recruitment_cycle_year, goto_confirmation: true))
  end

  def then_i_should_be_taken_back_to_the_confirm_page
    expect(page).to have_current_path(check_publish_provider_recruitment_cycle_accredited_providers_path(@provider.provider_code, @provider.recruitment_cycle_year))
  end

  def when_i_click_the_back_link
    click_on 'Back'
  end

  def then_i_should_be_taken_to_the_accredited_provider_search_page
    expect(page).to have_current_path(
      search_publish_provider_recruitment_cycle_accredited_providers_path(@provider.provider_code, @provider.recruitment_cycle_year, goto_confirmation: true)
    )
  end

  def when_i_click_the_change_link_for(field)
    within '.govuk-summary-list' do
      click_on "Change #{field}"
    end
  end

  def given_i_am_on_the_confirm_page
    given_there_are_accredited_providers_in_the_database
    when_i_click_add_accredited_provider
    when_i_search_for_an_accredited_provider_with_a_valid_query
    when_i_select_the_provider
    when_i_input_some_information
  end

  def and_i_should_see_a_success_message
    expect(page).to have_content('Accredited provider added')
  end

  def then_i_should_be_taken_to_the_index_page
    expect(page).to have_current_path(publish_provider_recruitment_cycle_accredited_providers_path(@provider.provider_code, @provider.recruitment_cycle_year))
  end

  def when_i_confirm_the_changes
    click_on 'Add accredited provider'
  end

  def then_i_should_see_the_information_i_added
    expect(page).to have_text('This is a description')
  end

  def when_i_input_some_information
    fill_in 'About the accredited provider', with: 'This is a description'
    click_continue
  end

  def and_i_search_with_an_invalid_query
    fill_in form_title, with: ''
    click_continue
  end

  def when_i_select_the_provider
    choose @accredited_provider.provider_name
    click_continue
  end

  def then_i_should_still_see_the_provider_i_searched_for
    expect(page).to have_content(@accredited_provider.provider_name)
    expect(page).not_to have_content(@accredited_provider_two.provider_name)
    expect(page).not_to have_content(@accredited_provider_three.provider_name)
  end

  def and_i_should_see_an_error_message(error_message = form_title)
    expect(page).to have_content(error_message)
  end

  alias_method :then_i_should_see_an_error_message, :and_i_should_see_an_error_message

  def when_i_continue_without_selecting_an_accredited_provider
    click_continue
  end

  def then_i_see_the_provider_i_searched_for
    expect(page).to have_content(@accredited_provider.provider_name)
    expect(page).not_to have_content(@accredited_provider_two.provider_name)
    expect(page).not_to have_content(@accredited_provider_three.provider_name)
  end

  def given_there_are_accredited_providers_in_the_database
    @accredited_provider = create(:provider, :accredited_provider, provider_name: 'UCL')
    @accredited_provider_two = create(:provider, :accredited_provider, provider_name: 'Accredited provider two')
    @accredited_provider_three = create(:provider, :accredited_provider, provider_name: 'Accredited provider three')
  end

  def when_i_search_for_an_accredited_provider_with_a_valid_query
    fill_in form_title, with: @accredited_provider.provider_name
    click_continue
  end

  def when_i_click_add_accredited_provider
    click_link 'Add accredited provider'
  end

  def then_i_see_the_correct_text_for_no_accredited_providers
    expect(page).to have_text("There are no accredited providers for #{@provider.provider_name}")
  end

  def when_i_click_on_the_accredited_provider_tab
    click_link 'Accredited provider'
  end

  alias_method :and_i_click_on_the_accredited_provider_tab, :when_i_click_on_the_accredited_provider_tab

  def and_i_visit_the_root_path
    visit root_path
  end

  def and_the_accredited_provider_search_feature_is_on
    allow(Settings.features).to receive(:accredited_provider_search).and_return(true)
  end

  def given_i_am_a_lead_school_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
    @provider = @current_user.providers.first
  end

  def form_title
    'Enter a provider name, UKPRN or postcode'
  end

  def click_continue
    click_on 'Continue'
  end

  alias_method :and_i_continue_without_entering_a_description, :click_continue

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
    expect(page).to have_selector('h2', text: 'Accrediting provider name')
  end
end
