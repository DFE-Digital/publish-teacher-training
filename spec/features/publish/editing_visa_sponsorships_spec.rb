# frozen_string_literal: true

require "rails_helper"

feature "Editing visa sponsorships", { can_edit_current_and_next_cycles: false } do
  scenario "as a lead school i cannot view any visa details" do
    given_i_am_authenticated_as_a_lead_school_provider_user
    when_i_visit_the_provider_details_page
    then_i_should_not_see_any_visa_details
  end

  scenario "as a scitt i can update the skilled worker visa sponsorships" do
    given_i_am_authenticated_as_a_scitt_provider_user
    when_i_visit_the_provider_details_page
    then_i_should_see_visa_details

    when_i_click_on_the_change_skilled_worker_visa_link
    and_i_set_my_skilled_worker_visa_sponsorships
    and_i_submit_skilled_worker_visas
    then_i_should_see_a_success_message
    and_the_skilled_worker_visa_sponsorship_is_updated
  end

  scenario "as an hei i can update the skilled worker visa sponsorships" do
    given_i_am_authenticated_as_a_hei_provider_user
    when_i_visit_the_provider_details_page
    then_i_should_see_visa_details

    when_i_click_on_the_change_skilled_worker_visa_link
    and_i_set_my_skilled_worker_visa_sponsorships
    and_i_submit_skilled_worker_visas
    then_i_should_see_a_success_message
    and_the_skilled_worker_visa_sponsorship_is_updated

    when_i_click_on_the_change_student_visa_link
    and_i_set_my_student_visa_sponsorships
    and_i_submit_student_visas
    then_i_should_see_a_success_message
    and_the_student_visa_sponsorship_is_updated
  end

  def given_i_am_authenticated_as_a_lead_school_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
    provider.update!(provider_type: "lead_school")
  end

  def given_i_am_authenticated_as_a_scitt_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
    provider.update!(provider_type: "scitt", can_sponsor_student_visa: false, can_sponsor_skilled_worker_visa: false)
  end

  def given_i_am_authenticated_as_a_hei_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
    provider.update!(provider_type: "university", can_sponsor_student_visa: false, can_sponsor_skilled_worker_visa: false)
  end

  def when_i_visit_the_provider_details_page
    provider_details_show_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def then_i_should_not_see_any_visa_details
    expect(page).not_to have_content("Visa sponsorship")
  end

  def then_i_should_see_visa_details
    expect(page).to have_content("Visa sponsorship")
    expect(page).to have_content("Student visa")
    expect(page).to have_content("Skilled Worker visa")
  end

  def when_i_click_on_the_change_skilled_worker_visa_link
    provider_details_show_page.skilled_worker_visa_link.click
  end

  def when_i_click_on_the_change_student_visa_link
    provider_details_show_page.student_visa_link.click
  end

  def and_i_set_my_skilled_worker_visa_sponsorships
    provider_skilled_worker_visa_sponsorships_page.can_sponsor_skilled_worker_visa.choose
  end

  def and_i_set_my_student_visa_sponsorships
    provider_student_visa_sponsorships_page.can_sponsor_student_visa.choose
  end

  def and_i_submit_skilled_worker_visas
    provider_skilled_worker_visa_sponsorships_page.update_skilled_worker_visas.click
  end

  def and_i_submit_student_visas
    provider_student_visa_sponsorships_page.update_student_visas.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.visa_changes"))
  end

  def and_the_skilled_worker_visa_sponsorship_is_updated
    provider.reload

    expect(provider.can_sponsor_skilled_worker_visa).to be true
  end

  def and_the_student_visa_sponsorship_is_updated
    provider.reload

    expect(provider.can_sponsor_student_visa).to be true
  end

  def provider
    @current_user.providers.first
  end
end
