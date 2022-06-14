# frozen_string_literal: true

require "rails_helper"

feature "Editing visa sponsorships", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_provider_visa_sponsorships_page
  end

  scenario "i can update my visa sponsorships" do
    and_i_set_my_visa_sponsorships
    and_i_submit
    then_i_should_see_a_success_message
    and_the_visa_sponsorships_are_updated
  end

  scenario "updating with invalid data" do
    and_i_submit
    then_i_should_see_a_an_error_message
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
    provider.update!(can_sponsor_student_visa: nil, can_sponsor_skilled_worker_visa: nil)
  end

  def when_i_visit_the_provider_visa_sponsorships_page
    provider_visa_sponsorships_page.load(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year)
  end

  def and_i_set_my_visa_sponsorships
    provider_visa_sponsorships_page.can_sponsor_student_visa.choose
    provider_visa_sponsorships_page.can_sponsor_skilled_worker_visa.choose
  end

  def and_i_submit
    provider_visa_sponsorships_page.save_and_publish.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.published"))
  end

  def and_the_visa_sponsorships_are_updated
    provider.reload

    expect(provider.can_sponsor_student_visa).to be true
    expect(provider.can_sponsor_skilled_worker_visa).to be true
  end

  def then_i_should_see_a_an_error_message
    expect(page).to have_content("Select if candidates can get a sponsored Student visa")
  end

  def provider
    @current_user.providers.first
  end
end
