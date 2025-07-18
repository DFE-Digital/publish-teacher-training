require "rails_helper"

RSpec.describe "Support console Candidates index", service: :support do
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  scenario "user sees candidates index" do
    when_some_candidates_exist
    and_i_visit_the_candidate_index
    then_i_see_the_candidates_listed
  end

  def when_some_candidates_exist
    @candidates = create_list(:candidate, 2)
  end

  def and_i_visit_the_candidate_index
    visit support_candidates_path
  end

  def then_i_see_the_candidates_listed
    expect(page).to have_content(@candidates[0].email_address)
    expect(page).to have_content(@candidates[1].email_address)
  end

  def given_i_am_authenticated
    sign_in_system_test(user:)
  end
end
