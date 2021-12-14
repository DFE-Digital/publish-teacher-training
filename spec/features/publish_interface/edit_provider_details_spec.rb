# frozen_string_literal: true

require "rails_helper"

feature "About Your Organisation section" do
  scenario "Provider user edits provider details" do
    given_i_am_a_provider_user
    and_my_provider_has_accrediting_providers
    when_i_visit_the_details_page
    then_i_can_edit_info_about_training_with_us
    then_i_can_edit_info_about_our_accredited_bodies
    then_i_can_edit_info_about_disabilities_and_other_needs
    # TODO: then_i_can_edit_info_about_visa_sponsorship
    then_i_can_edit_contact_details
  end

  def given_i_am_a_provider_user
    @current_user = create(:user, :with_provider)
    @provider = @current_user.providers.first
    # Mark visa fields as false - switch to true when implementing visa section
    @provider.update!(can_sponsor_student_visa: false, can_sponsor_skilled_worker_visa: false)
    user_exists_in_dfe_sign_in(user: @current_user)
  end

  def and_my_provider_has_accrediting_providers
    @provider.courses << create(:course, :with_accrediting_provider)
    @accrediting_provider = @provider.accrediting_providers.first
  end

  def when_i_visit_the_details_page
    visit details_publish_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year)
    click_button "Sign in using DfE Sign-in"
  end

  def then_i_can_edit_info_about_training_with_us
    click_link "Change details about training with your organisation"
    fill_in "Training with you", with: ""
    click_button "Save and publish changes"
    within ".govuk-error-summary__body" do
      expect(page).to have_content "Enter details about training with you"
    end

    fill_in "Training with you", with: "Updated: Training with you"
    click_button "Save and publish changes"

    expect(page).to have_content "Your changes have been published"
    within_summary_row "Training with your organisation" do
      expect(page).to have_content "Updated: Training with you"
    end
  end

  def then_i_can_edit_info_about_our_accredited_bodies
    click_link "Change details about #{@accrediting_provider.provider_name}"
    fill_in @accrediting_provider.provider_name, with: "Updated: accredited body description"
    click_button "Save and publish changes"

    expect(page).to have_content "Your changes have been published"
    within_summary_row @accrediting_provider.provider_name do
      expect(page).to have_content "Updated: accredited body description"
    end
  end

  def then_i_can_edit_info_about_disabilities_and_other_needs
    click_link "Change details about training with disabilities and other needs"
    fill_in "Training with disabilities and other needs", with: "Updated: training with disabilities"
    click_button "Save and publish changes"

    expect(page).to have_content "Your changes have been published"
    within_summary_row "Training with disabilities and other needs" do
      expect(page).to have_content "Updated: training with disabilities"
    end
  end

  def then_i_can_edit_contact_details
    click_link "Change email address"

    fill_in "Email address", with: "updated@email.com"
    fill_in "Telephone number", with: "11111 111111"
    fill_in "Building and street", with: "123 Updated Street"
    click_button "Save and publish changes"

    expect(page).to have_content "Your changes have been published"
    within_summary_row "Email address" do
      expect(page).to have_content "updated@email.com"
    end
    within_summary_row "Telephone number" do
      expect(page).to have_content "11111 111111"
    end
    within_summary_row "Contact address" do
      expect(page).to have_content "123 Updated Street"
    end
  end
end
