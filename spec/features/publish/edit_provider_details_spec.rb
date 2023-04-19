# frozen_string_literal: true

require 'rails_helper'

feature 'About Your Organisation section', { can_edit_current_and_next_cycles: false } do
  scenario 'Provider user edits provider details' do
    given_i_am_a_provider_user_as_a_provider_user
    and_my_provider_has_accrediting_providers
    when_i_visit_the_details_page
    then_i_can_edit_info_about_training_with_us
    then_i_can_edit_info_about_our_accredited_bodies
    then_i_can_edit_info_about_disabilities_and_other_needs
  end

  def given_i_am_a_provider_user_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
    @provider = @current_user.providers.first
  end

  def and_my_provider_has_accrediting_providers
    @provider.courses << create(:course, :with_accrediting_provider)
    @accrediting_provider = @provider.accrediting_providers.first
  end

  def when_i_visit_the_details_page
    publish_provider_details_show_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year
    )
  end

  def then_i_can_edit_info_about_training_with_us
    publish_provider_details_show_page.train_with_us_link.click
    expect(page).to have_current_path publish_provider_details_edit_page.url(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year
    )

    publish_provider_details_edit_page.training_with_you_field.set ''
    publish_provider_details_edit_page.save_and_publish.click
    within publish_provider_details_edit_page.error_summary do
      expect(page).to have_content 'Enter details about training with you'
    end

    publish_provider_details_edit_page.training_with_you_field.set 'Updated: Training with you'
    publish_provider_details_edit_page.save_and_publish.click

    expect(page).to have_content 'Your changes have been published'
    within_summary_row 'Training with your organisation' do
      expect(page).to have_content 'Updated: Training with you'
    end
  end

  def then_i_can_edit_info_about_our_accredited_bodies
    click_link "Change details about #{@accrediting_provider.provider_name}"

    publish_provider_details_edit_page.accredited_body_description_field.set 'Updated: accredited provider description'
    publish_provider_details_edit_page.save_and_publish.click

    expect(page).to have_content 'Your changes have been published'
    within_summary_row @accrediting_provider.provider_name do
      expect(page).to have_content 'Updated: accredited provider description'
    end
  end

  def then_i_can_edit_info_about_disabilities_and_other_needs
    publish_provider_details_show_page.train_with_disability_link.click

    publish_provider_details_edit_page.train_with_disability_field.set 'Updated: training with disabilities'
    publish_provider_details_edit_page.save_and_publish.click

    expect(page).to have_content 'Your changes have been published'
    within_summary_row 'Training with disabilities and other needs' do
      expect(page).to have_content 'Updated: training with disabilities'
    end
  end
end
