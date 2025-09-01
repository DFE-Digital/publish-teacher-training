require "rails_helper"

RSpec.describe "Support console Candidates details" do
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  scenario "user sees candidates details" do
    when_a_candidates_exist
    and_i_visit_the_candidate_details
    then_i_see_the_details_of_the_candidate
  end

  def when_a_candidates_exist
    @candidate = create(:candidate)
  end

  def and_i_visit_the_candidate_details
    visit details_support_candidate_path(@candidate)
  end

  def then_i_see_the_details_of_the_candidate
    expect(page).to have_content(@candidate.email_address)
    expect(page).to have_content(@candidate.created_at.to_fs(:govuk_date_and_time))
    expect(page).to have_content("Never logged in")
  end

  def given_i_am_authenticated
    sign_in_system_test(user:)
  end
end
