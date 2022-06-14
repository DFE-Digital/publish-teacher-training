# frozen_string_literal: true

require "rails_helper"

feature "Accepting terms" do
  before do
    given_the_new_publish_flow_feature_flag_is_enabled
    given_i_am_a_user_who_has_not_accepted_the_terms
    when_i_visit_the_publish_service
  end

  scenario "i can accept the terms and conditions" do
    then_i_am_taken_to_the_terms_page
    when_i_accept_the_terms_and_conditions
    then_i_should_be_redirected_to_the_courses_index_page
    and_the_user_is_marked_as_accepting_the_terms
  end

  scenario "i am shown an error if i do not accept the terms" do
    and_i_do_not_accept_the_terms_and_conditions
    then_i_should_see_an_error_message
  end

  def given_the_new_publish_flow_feature_flag_is_enabled
    enable_features(:new_publish_navigation)
  end

  def given_i_am_a_user_who_has_not_accepted_the_terms
    given_i_am_authenticated(user: create(:user, :with_provider, accept_terms_date_utc: nil))
  end

  def when_i_visit_the_publish_service
    visit(root_path)
  end

  def then_i_am_taken_to_the_terms_page
    expect(terms_page).to be_displayed
  end

  def when_i_accept_the_terms_and_conditions
    terms_page.accept_terms.check
    and_i_submit
  end

  def then_i_should_be_redirected_to_the_courses_index_page
    expect(provider_courses_index_page).to be_displayed
  end

  def and_the_user_is_marked_as_accepting_the_terms
    expect(@current_user.reload.accepted_terms?).to be true
  end

  def and_i_do_not_accept_the_terms_and_conditions
    and_i_submit
  end

  def and_i_submit
    terms_page.submit.click
  end

  def then_i_should_see_an_error_message
    expect(course_study_mode_edit_page.error_messages).to include(
      I18n.t("activemodel.errors.models.publish/interruption/accept_terms_form.attributes.terms_accepted.accepted"),
    )
  end
end
