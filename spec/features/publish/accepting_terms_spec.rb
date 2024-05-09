# frozen_string_literal: true

require 'rails_helper'

feature 'Accepting terms', { can_edit_current_and_next_cycles: false } do
  scenario 'i can accept the terms and conditions' do
    given_i_am_a_user_who_has_not_accepted_the_terms
    when_i_visit_the_publish_service
    then_i_am_taken_to_the_publish_terms_page
    when_i_accept_the_terms_and_conditions
    then_i_should_be_redirected_to_the_courses_index_page
    and_the_user_is_marked_as_accepting_the_terms
  end

  scenario 'i am shown an error if i do not accept the terms' do
    given_i_am_a_user_who_has_not_accepted_the_terms
    when_i_visit_the_publish_service
    and_i_do_not_accept_the_terms_and_conditions
    then_i_should_see_an_error_message
  end

  scenario 'not logged in and navigate directly to the terms page' do
    given_i_visit_the_terms_and_conditions_page
    then_i_should_be_redirected_to_the_sign_in_page
  end

  def given_i_visit_the_terms_and_conditions_page
    visit publish_accept_terms_path
  end

  def then_i_should_be_redirected_to_the_sign_in_page
    expect(page).to have_current_path(sign_in_path)
  end

  def given_i_am_a_user_who_has_not_accepted_the_terms
    given_i_am_authenticated(user: create(:user, :with_provider, accept_terms_date_utc: nil))
  end

  def when_i_visit_the_publish_service
    visit(root_path)
  end

  def then_i_am_taken_to_the_publish_terms_page
    expect(publish_terms_page).to be_displayed
  end

  def when_i_accept_the_terms_and_conditions
    publish_terms_page.accept_terms.check
    and_i_submit
  end

  def then_i_should_be_redirected_to_the_courses_index_page
    expect(publish_provider_courses_index_page).to be_displayed
  end

  def and_the_user_is_marked_as_accepting_the_terms
    expect(@current_user.reload.accepted_terms?).to be true
  end

  def and_i_do_not_accept_the_terms_and_conditions
    and_i_submit
  end

  def and_i_submit
    publish_terms_page.submit.click
  end

  def then_i_should_see_an_error_message
    expect(publish_course_study_mode_edit_page.error_messages).to include(
      I18n.t('activemodel.errors.models.publish/interruption/accept_terms_form.attributes.terms_accepted.accepted')
    )
  end
end
