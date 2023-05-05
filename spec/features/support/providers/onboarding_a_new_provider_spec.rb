# frozen_string_literal: true

require 'rails_helper'

feature 'Onboarding a new provider' do
  describe 'adding provider details' do
    before do
      given_i_am_authenticated(user:)
      and_i_visit_the_onboarding_a_new_provider_page
    end

    %i[university lead_school scitt].each do |provider_type|
      scenario "add a new #{provider_type} provider" do
        when_i_fill_in_a_valid_provider_details(provider_type:)
        and_i_click_the_continue_button
        then_i_am_redirected_to_the_onboarding_contacts_page
      end
    end

    scenario 'with invalid details' do
      when_i_click_the_continue_button
      then_i_see_the_error_summary
    end

    scenario 'back link return to correct page' do
      when_i_click_on 'Back'
      then_i_am_redirected_back_to_the_support_providers_index_page
    end

    scenario 'cancel link return to correct page' do
      when_i_click_on 'Cancel'
      then_i_am_redirected_back_to_the_support_providers_index_page
    end
  end

  %i[university lead_school scitt].each do |provider_type|
    describe "adding contact details for #{provider_type} provider" do
      before do
        given_i_am_authenticated(user:)
        and_i_visit_the_onboarding_a_new_provider_page
        and_i_fill_in_a_valid_provider_details(provider_type:)
        and_i_click_the_continue_button
        and_i_am_redirected_to_the_onboarding_contacts_page
      end

      scenario 'add a new provider contact details' do
        when_i_fill_in_a_valid_provider_contact_details
        and_i_click_the_continue_button
        then_i_am_redirected_to_check_your_answer_page
      end

      scenario 'with invalid details' do
        when_i_click_the_continue_button
        then_i_see_the_error_summary
      end

      scenario 'back link return to correct page' do
        when_i_click_on 'Back'
        then_i_am_redirected_back_to_the_onboarding_page
        and_the_provider_form_should_be_prefilled_with_the_provider_details(provider_type:)
      end

      scenario 'cancel link return to correct page' do
        when_i_click_on 'Cancel'
        then_i_am_redirected_back_to_the_support_providers_index_page
      end
    end

    describe "checking details for #{provider_type} provider" do
      before do
        given_i_am_authenticated(user:)
        and_i_visit_the_onboarding_a_new_provider_page
        and_i_fill_in_a_valid_provider_details(provider_type:)
        and_i_click_the_continue_button
        and_i_am_redirected_to_the_onboarding_contacts_page
        and_i_fill_in_a_valid_provider_contact_details
        and_i_click_the_continue_button
        and_i_am_redirected_to_check_your_answer_page
      end

      scenario 'add organsisation' do
        and_i_click_the_add_organisation_button
        then_i_am_redirected_to_provider_page
        and_a_success_message_is_displayed
      end

      scenario 'back link return to correct page' do
        when_i_click_on 'Back'
        and_i_am_redirected_to_the_onboarding_contacts_page
        and_the_provider_contact_form_should_be_prefilled
      end

      scenario 'cancel link return to correct page' do
        when_i_click_on 'Cancel'
        then_i_am_redirected_back_to_the_support_providers_index_page
      end

      scenario 'change links for provider details' do
        when_i_click_on 'Change provider name'
        and_the_provider_form_should_be_prefilled_with_the_provider_details(provider_type:)
        and_i_click_the_continue_button
        and_i_am_redirected_to_check_your_answer_page
        and_i_click_on 'Change provider code'
        and_the_provider_form_should_be_prefilled_with_the_provider_details(provider_type:)
        and_i_click_on 'Back'
        then_i_am_redirected_to_check_your_answer_page
      end

      scenario 'change links for provider contact details' do
        when_i_click_on 'Change email address'
        and_the_provider_contact_form_should_be_prefilled
        and_i_click_the_continue_button
        and_i_am_redirected_to_check_your_answer_page
        and_i_click_on 'Change telephone number'
        and_the_provider_contact_form_should_be_prefilled
        and_i_click_on 'Back'
        then_i_am_redirected_to_check_your_answer_page
      end
    end
  end

  private

  def user
    @user ||= create(:user, :admin)
  end

  def and_there_is_a_recruitment_cycle
    find_or_create(:recruitment_cycle)
  end

  def and_a_success_message_is_displayed
    expect(page).to have_content('Organisation added')
  end

  def and_i_visit_the_onboarding_a_new_provider_page
    visit "/support/#{Settings.current_recruitment_cycle_year}/providers/onboarding/new"
  end

  def when_i_fill_in_a_valid_provider_contact_details
    fill_in 'Email address', with: 'test@example.com'
    fill_in 'Telephone number', with: '01234 567890'
    fill_in 'Website', with: 'https://www.example.com'
    fill_in 'Address line 1', with: 'Address line 1'
    fill_in 'Town or city', with: 'Towen'
    fill_in 'Postcode', with: 'BN1 1AA'
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

  def and_the_provider_contact_form_should_be_prefilled
    expect(page).to have_field('Email address', with: 'test@example.com')
    expect(page).to have_field('Telephone number', with: '01234 567890')
    expect(page).to have_field('Website', with: 'https://www.example.com')
    expect(page).to have_field('Address line 1', with: 'Address line 1')
    expect(page).to have_field('Town or city', with: 'Towen')
    expect(page).to have_field('Postcode', with: 'BN1 1AA')
  end

  def and_the_provider_form_should_be_prefilled_with_the_provider_details(provider_type:)
    expect(page).to have_field('Provider name', with: 'My favourite provider')
    expect(page).to have_field('Provider code', with: 'A32')
    expect(page).to have_field('UK provider reference number (UKPRN)', with: '12341234')

    case provider_type
    when :lead_school
      expect(page).to have_checked_field('No')

      expect(page).to have_checked_field('School')
      expect(page).to have_field('Unique reference number (URN)', with: '54321')
    when :university
      expect(page).to have_checked_field('Yes')
      expect(page).to have_field('Accredited provider ID', with: '1111')

      expect(page).to have_checked_field('Higher education institution (HEI)')
    when :scitt
      expect(page).to have_checked_field('Yes')
      expect(page).to have_field('Accredited provider ID', with: '5555')

      expect(page).to have_checked_field('School centred initial teacher training (SCITT)')
    end
  end

  def and_i_click_the_add_organisation_button
    click_button 'Add organisation'
  end

  def and_i_click_the_continue_button
    click_button 'Continue'
  end

  def then_i_am_redirected_to_provider_page
    expect(page).to have_current_path("/support/#{Settings.current_recruitment_cycle_year}/providers/#{Provider.last.id}")
  end

  def then_i_am_redirected_to_check_your_answer_page
    expect(page).to have_current_path("/support/#{Settings.current_recruitment_cycle_year}/providers/onboarding/check")
  end

  def then_i_am_redirected_to_the_onboarding_contacts_page
    expect(page).to have_current_path("/support/#{Settings.current_recruitment_cycle_year}/providers/onboarding/contacts/new")
  end

  def then_i_am_redirected_back_to_the_onboarding_page
    expect(page).to have_current_path("/support/#{Settings.current_recruitment_cycle_year}/providers/onboarding/new")
  end

  def then_i_am_redirected_back_to_the_support_providers_index_page
    expect(page).to have_current_path("/support/#{Settings.current_recruitment_cycle_year}/providers")
  end

  def then_i_see_the_error_summary
    expect(page.find('.govuk-error-summary')).to be_visible
  end

  alias_method :when_i_click_the_continue_button, :and_i_click_the_continue_button
  alias_method :when_i_click_on, :click_on
  alias_method :and_i_click_on, :click_on
  alias_method :and_i_fill_in_a_valid_provider_details, :when_i_fill_in_a_valid_provider_details
  alias_method :and_i_am_redirected_to_the_onboarding_contacts_page, :then_i_am_redirected_to_the_onboarding_contacts_page
  alias_method :and_i_fill_in_a_valid_provider_contact_details, :when_i_fill_in_a_valid_provider_contact_details
  alias_method :and_i_am_redirected_to_check_your_answer_page, :then_i_am_redirected_to_check_your_answer_page
end
