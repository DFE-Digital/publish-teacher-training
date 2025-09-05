require "rails_helper"

RSpec.describe "Filter candidates" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_are_candidates
    when_i_visit_the_support_users_index_page
  end

  scenario "filtering candidates" do
    then_i_can_search_by_email
    and_when_i_click_apply_filters
    then_i_only_see_one_candidate
  end

  scenario "clearing filters" do
    when_i_applied_filters
    and_then_i_clear_filters
    then_i_should_see_all_candidates
  end

  def when_i_applied_filters
    then_i_can_search_by_email
    and_when_i_click_apply_filters
    then_i_only_see_one_candidate
    expect(page).to have_content(@candidate_one.email_address)
    expect(page).to have_no_content(@candidate_two.email_address)
  end

  def and_then_i_clear_filters
    click_link_or_button("Clear")
  end

  def then_i_should_see_all_candidates
    expect(page).to have_content(@candidate_one.email_address)
    expect(page).to have_content(@candidate_two.email_address)
  end

  def and_there_are_candidates
    @candidate_one = create(:candidate, email_address: "barry@gmail.com")
    @candidate_two = create(:candidate, email_address: "george@gmail.com")
  end

  def when_i_visit_the_support_users_index_page
    visit support_candidates_path
    expect(page).to have_content(@candidate_one.email_address)
    expect(page).to have_content(@candidate_two.email_address)
  end

  def then_i_can_search_by_email
    fill_in "Email address", with: "barry"
  end

  def and_when_i_click_apply_filters
    click_link_or_button("Apply filters")
  end

  def then_i_only_see_one_candidate
    expect(page).to have_content(@candidate_one.email_address)
    expect(page).to have_no_content(@candidate_two.email_address)
  end
end
