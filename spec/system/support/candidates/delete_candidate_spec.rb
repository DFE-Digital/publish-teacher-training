require "rails_helper"

RSpec.describe "Support console deleting a candidate" do
  let(:user) { create(:user, :admin) }

  before { sign_in_system_test(user:) }

  scenario "user deletes a candidate and their saved courses" do
    candidate = create(:candidate)
    create(:saved_course, candidate:)
    create(:saved_course, candidate:, course: create(:course))

    visit details_support_candidate_path(candidate)
    click_link_or_button "Delete this candidate"
    click_link_or_button "Remove candidate"

    expect(page).to have_current_path(support_candidates_path)
    expect(page).to have_content("Candidate successfully deleted")

    expect(Candidate.exists?(candidate.id)).to be(false)
    expect(SavedCourse.where(candidate_id: candidate.id)).to be_empty
  end

  scenario "user deletes a candidate and their recent searches" do
    candidate = create(:candidate)
    create(:recent_search, find_candidate: candidate)
    create(:recent_search, find_candidate: candidate, search_attributes: { provider_name: "Test provider" })

    visit details_support_candidate_path(candidate)
    click_link_or_button "Delete this candidate"
    click_link_or_button "Remove candidate"

    expect(page).to have_current_path(support_candidates_path)
    expect(page).to have_content("Candidate successfully deleted")

    expect(Candidate.exists?(candidate.id)).to be(false)
    expect(RecentSearch.where(find_candidate_id: candidate.id)).to be_empty
  end

  scenario "user sees an error when candidate deletion fails" do
    candidate = create(:candidate)
    allow(Candidate).to receive(:find).and_call_original
    allow(Candidate).to receive(:find).with(candidate.id.to_s).and_return(candidate)
    allow(candidate).to receive(:destroy!).and_return(false)

    visit details_support_candidate_path(candidate)
    click_link_or_button "Delete this candidate"
    click_link_or_button "Remove candidate"

    expect(page).to have_current_path(support_candidates_path)
    expect(page).to have_content("This candidate could not be deleted")

    expect(Candidate.exists?(candidate.id)).to be(true)
  end
end
