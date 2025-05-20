require "rails_helper"

RSpec.describe "Support console feedback view", service: :support do
  let(:user) { create(:user, :admin) }

  context "when navigating to the feedback page via the support console" do
    before do
      given_i_am_authenticated
      when_i_navigate_to_the_feedback_page
    end

    scenario "user sees feedback table" do
      then_i_see_feedback_table
      and_expect_to_see_feedback_entries
    end

    scenario "check for backlink presence and navigation on feedback page" do
      then_i_see_backlink_to_support_homepage
      click_link_or_button "Back"
      then_i_am_on_the_support_homepage
    end
  end

  context "with more than one page of feedback" do
    before do
      create_list(:feedback, 15)
      given_i_am_authenticated
      when_i_visit_the_feedback_page
    end

    scenario "user sees pagination controls and can navigate to next page" do
      expect(page).to have_selector("table tbody tr", count: 10)
      expect(page).to have_link("Next")

      click_link "Next"

      expect(page).to have_selector("table tbody tr", count: 5)
      expect(page).to have_link("Previous")
    end
  end

  def given_i_am_authenticated
    sign_in_system_test(user:)
  end

  def when_i_navigate_to_the_feedback_page
    visit support_root_path
    click_link "Feedback"
  end

  def when_i_visit_the_feedback_page
    visit support_feedback_index_path
  end

  def then_i_see_feedback_table
    expect(page).to have_content("Feedback on Find teacher training courses")
    expect(page).to have_content("ID")
    expect(page).to have_content("Ease of use")
    expect(page).to have_content("User experience")
    expect(page).to have_content("Created at")
  end

  def and_expect_to_see_feedback_entries
    Feedback.order(created_at: :desc).limit(10).each do |feedback|
      expect(page).to have_content(feedback.id)
      expect(page).to have_content(feedback.ease_of_use)
      expect(page).to have_content(feedback.experience)
      expect(page).to have_content(feedback.created_at.strftime("%d %B %Y"))
    end
  end

  def then_i_see_backlink_to_support_homepage
    expect(page).to have_link("Back", href: support_root_path)
  end

  def then_i_am_on_the_support_homepage
    expect(page).to have_current_path(support_recruitment_cycle_providers_path(Settings.current_recruitment_cycle_year))
  end
end
