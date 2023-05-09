# frozen_string_literal: true

require 'rails_helper'

feature 'View provider users' do
  let(:user) { create(:user, :admin) }

  before do
    given_i_am_authenticated(user:)
    and_there_is_a_provider
    when_i_visit_the_support_provider_show_page
    then_i_can_view_provider_details
  end

  context 'valid details' do
    scenario "I can edit a provider's name (provider detail)" do
      when_i_click_on_the_change_link
      then_i_am_on_the_support_provider_edit_page
      when_i_fill_in_a_valid_provider_name
      and_i_choose_a_different_provider_type
      and_i_fill_in_a_valid_id
      and_i_click_the_submit_button
      then_i_am_redirected_back_to_the_support_provider_show_page
      and_the_provider_details_are_updated
    end

    scenario "I can edit a provider's email (provider contact detail)" do
      when_i_click_on_the_change_email_link
      then_i_am_on_the_support_provider_edit_contact_details_page
      when_i_fill_in_a_valid_email
      and_i_click_the_submit_button
      then_i_am_redirected_back_to_the_support_provider_show_page
      and_the_provider_contact_details_are_updated
    end
  end

  context 'invalid details' do
    scenario "I cannot edit a provider's name (provider detail)" do
      when_i_click_on_the_change_link
      then_i_am_on_the_support_provider_edit_page
      when_i_fill_in_an_invalid_provider_name
      and_i_click_the_submit_button
      then_i_see_the_error_summary
    end

    scenario "I cannot edit a provider's email (provider contact detail)" do
      when_i_click_on_the_change_email_link
      then_i_am_on_the_support_provider_edit_contact_details_page
      when_i_fill_in_an_invalid_email
      and_i_click_the_submit_button
      then_i_see_the_contact_details_error_summary
    end
  end

  private

  def and_there_is_a_provider
    @provider = create(:provider, :accredited_provider, :scitt, provider_name: 'Provider 1', accredited_provider_id: 5432)
  end

  def when_i_visit_the_support_provider_show_page
    support_provider_show_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, id: @provider.id)
  end

  def then_i_can_view_provider_details
    expect(support_provider_show_page).to have_text('Provider 1')
    expect(support_provider_show_page).to have_text('Yes')
    expect(support_provider_show_page).to have_text('SCITT')
  end

  def when_i_click_on_the_change_link
    click_link 'Change provider name'
  end

  def when_i_click_on_the_change_email_link
    click_link 'Change provider email'
  end

  def then_i_am_on_the_support_provider_edit_page
    expect(support_provider_edit_page).to be_displayed
  end

  def then_i_am_on_the_support_provider_edit_contact_details_page
    expect(URI(current_url).path).to eq("/support/#{Settings.current_recruitment_cycle_year}/providers/#{@provider.id}/contact-details/edit")
  end

  def when_i_fill_in_a_valid_email
    fill_in 'support-contact-details-form-email-field', with: 'Jo@example.com'
  end

  def when_i_fill_in_an_invalid_email
    fill_in 'support-contact-details-form-email-field', with: 'Jo@example'
  end

  def when_i_fill_in_a_valid_provider_name
    support_provider_edit_page.provider_name.set('Provider 2')
  end

  def and_i_fill_in_a_valid_id
    fill_in 'provider-accredited-provider-id-field', with: '1234'
  end

  def and_i_choose_a_different_provider_type
    choose 'Higher education institute (HEI)'
  end

  def and_i_click_the_submit_button
    support_provider_edit_page.submit.click
  end

  def then_i_am_redirected_back_to_the_support_provider_show_page
    expect(support_provider_show_page).to be_displayed(id: @provider.id)
  end

  def and_the_provider_details_are_updated
    expect(support_provider_show_page).to have_text('Provider 2')
    expect(support_provider_show_page).to have_text('Yes')
    expect(support_provider_show_page).to have_text('University')
  end

  def and_the_provider_contact_details_are_updated
    expect(support_provider_show_page).to have_text('Jo@example.com')
  end

  def when_i_fill_in_an_invalid_provider_name
    support_provider_edit_page.provider_name.set(SecureRandom.hex(100))
  end

  def then_i_see_the_error_summary
    expect(support_provider_edit_page.error_summary).to be_visible
  end

  def then_i_see_the_contact_details_error_summary
    expect(page).to have_content('Enter an email address in the correct format, like name@example.com')
  end
end
