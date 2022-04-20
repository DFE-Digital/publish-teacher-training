# frozen_string_literal: true

require "rails_helper"

feature "Accepting rollover" do
  before do
    enable_features("rollover.can_edit_current_and_next_cycles")
    given_i_am_a_user_who_has_not_accepted_rollover
    when_i_visit_the_publish_service
  end

  after do
    disable_features("rollover.can_edit_current_and_next_cycles")
  end

  scenario "i can accept the rollover interruption" do
    then_i_am_taken_to_the_rollover_page
    when_i_accept_rollover
    then_i_should_be_returned_to_the_publish_service_page
    and_the_user_is_marked_as_accepting_rollover
  end

  def given_i_am_a_user_who_has_not_accepted_rollover
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def when_i_visit_the_publish_service
    visit(publish_root_path)
  end

  def then_i_am_taken_to_the_rollover_page
    expect(rollover_page).to be_displayed
  end

  def when_i_accept_rollover
    rollover_page.submit.click
  end

  def then_i_should_be_returned_to_the_publish_service_page
    expect(page).to have_current_path("/")
  end

  def and_the_user_is_marked_as_accepting_rollover
    expect(@current_user.reload.current_rollover_acceptance).to be_present
  end
end
