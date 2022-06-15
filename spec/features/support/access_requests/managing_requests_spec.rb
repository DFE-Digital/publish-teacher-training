# frozen_string_literal: true

require "rails_helper"

feature "Viewing and approving requests", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated(user: admin)
    and_there_are_access_requests
  end

  scenario "admin can view the requests" do
    when_i_visit_the_root_page
    then_i_should_see_a_link_to_view_the_requests
    when_i_click_on_the_link
    then_i_see_the_requests
  end

  scenario "admin can approve a request" do
    when_i_view_the_first_request
    and_i_approve_the_request
    then_the_request_should_be_approved
    and_i_should_see_steps_to_inform_the_publisher
  end

  scenario "admin can delete a request" do
    when_i_view_the_first_request
    and_i_delete_the_request
    then_the_request_should_be_deleted
  end

private

  def and_there_are_access_requests
    create_list(:access_request, 2, :requested)
  end

  def when_i_visit_the_root_page
    visit(root_path)
  end

  def then_i_should_see_a_link_to_view_the_requests
    expect(footer_page).to have_access_requests_link
    expect(footer_page.access_requests_link).to have_text("Access Requests (2)")
  end

  def when_i_click_on_the_link
    footer_page.access_requests_link.click
  end

  def then_i_see_the_requests
    expect(support_index_page).to be_displayed
    expect(support_index_page.requests.size).to eq(2)
  end

  def when_i_view_the_first_request
    support_index_page.load
    support_index_page.requests.first.view_request.click
    expect(support_confirm_page).to be_displayed
  end

  def and_i_approve_the_request
    support_confirm_page.approve.click
  end

  def and_i_delete_the_request
    support_confirm_page.delete.click
  end

  def then_the_request_should_be_approved
    expect(page).to have_text("Successfully approved request")
  end

  def then_the_request_should_be_deleted
    expect(support_index_page).to have_text("Successfully deleted the Access Request")
    expect(support_index_page.requests.size).to eq(1)
  end

  def and_i_should_see_steps_to_inform_the_publisher
    expect(page).to have_text("Inform the publisher")
  end

  def admin
    @admin ||= create(:user, :admin)
  end
end
