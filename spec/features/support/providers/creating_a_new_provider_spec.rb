# frozen_string_literal: true

require 'rails_helper'

feature 'Creating a provider' do
  before do
    given_i_am_authenticated(user:)
    when_i_visit_the_new_provider_page
  end

  %i[university lead_school scitt].each do |provider_type|
    scenario "add a new #{provider_type} provider" do
      when_i_fill_in_a_valid_provider_details(provider_type:)
      and_i_click_the_continue_button
      then_i_am_redirected_back_to_the_support_providers_index_page
      and_a_success_message_is_displayed
    end
  end

  scenario 'with invalid details' do
    when_i_click_the_continue_button
    then_i_see_the_error_summary
  end

  scenario 'back link return to correct page' do
    when_i_click_the_back_link
    then_i_am_redirected_back_to_the_support_providers_index_page
  end

  private

  def user
    @user ||= create(:user, :admin)
  end

  def and_a_success_message_is_displayed
    expect(page).to have_content('Provider was successfully created')
  end

  def when_i_visit_the_new_provider_page
    visit "/support/#{Settings.current_recruitment_cycle_year}/providers/onboarding/new"
  end

  def when_i_fill_in_a_valid_provider_details(provider_type:)
    fill_in 'Provider name', with: 'My favourite provider'
    fill_in 'Provider code', with: 'A32'
    fill_in 'UK provider reference number (UKPRN)', with: '12341234'

    case provider_type
    when :lead_school
      choose 'No'

      choose 'School'
      fill_in 'Unique reference number (URN)', with: '54321'
    when :university
      choose 'Yes'
      fill_in 'Accredited provider ID', with: '1111'

      choose 'Higher education institution (HEI)'
    when :scitt
      choose 'Yes'
      fill_in 'Accredited provider ID', with: '5555'

      choose 'School centred initial teacher training (SCITT)'
    end
  end

  def and_i_click_the_continue_button
    click_button 'Continue'
  end

  def when_i_click_the_back_link
    click_on 'Back'
  end

  def then_i_am_redirected_back_to_the_support_providers_index_page
    expect(page).to have_current_path("/support/#{Settings.current_recruitment_cycle_year}/providers")
  end

  def then_i_see_the_error_summary
    expect(page.find('.govuk-error-summary')).to be_visible
  end

  alias_method :when_i_click_the_continue_button, :and_i_click_the_continue_button
end
