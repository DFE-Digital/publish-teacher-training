require "rails_helper"

RSpec.describe "Support console feedback view", service: :support do
  include ActionView::Helpers::TextHelper
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  context "when navigating to the feedback page via the support console" do
    before do
      when_i_navigate_to_the_feedback_page
    end

    scenario "user sees feedback table" do
      then_i_see_feedback_table
      then_i_see_recent_feedback_entries
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
      when_i_visit_the_feedback_page
    end

    scenario "user sees pagination controls and can navigate to next page" do
      then_i_see_first_page_of_feedback_with_pagination

      click_link "Next"

      then_i_see_second_page_of_feedback_with_pagination
    end
  end

  context "when a feedback experience is over the truncation limit" do
    let!(:long_feedback) do
      create(:feedback, experience: "This is a very long feedback message designed to be more than 100 characters long so that it can trigger the truncation logic and display the 'View full' link.")
    end

    before do
      when_i_visit_the_feedback_page
    end

    scenario "displays truncated experience with 'view full' link, leading user to feedback details show page with bespoke backlink" do
      then_i_see_truncated_feedback_with_link(long_feedback)

      when_i_click_to_view_full_feedback

      then_i_see_the_feedback_details_page_for(long_feedback)

      then_i_see_backlink_to_feedback_list
      click_link "All feedback responses"
      then_i_am_on_the_feedback_list_page
    end
  end

  context "when I visit the download link for feedback data" do
    before do
      when_i_visit_the_feedback_page
    end

    scenario "I see a link to download feedback data as CSV" do
      expect(page).to have_link("Download feedback (CSV)", href: support_feedback_index_path(format: :csv))
    end

    scenario "clicking the download link redirects to the CSV export" do
      click_link "Download feedback (CSV)"
      then_i_download_the_feedback_data_as_csv
    end
  end

  context "when I want to download feedback data as a CSV file" do
    let!(:feedback) { create(:feedback, id: 1, ease_of_use: "easy", experience: "Great experience", created_at: "2025/07/10") }

    before do
      when_i_download_the_feedback_data_as_csv
    end

    scenario "user can download feedback data" do
      expect(page.response_headers["Content-Type"]).to include "text/csv"
      expect(page.response_headers["Content-Disposition"]).to include "attachment; filename=\"feedbacks-#{Time.zone.today}.csv\""
      expect(page.body).to include("ID,Ease of use,User experience,Created at")
      expect(page.body).to include("1,easy,Great experience,2025-07-10")
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

  def then_i_see_recent_feedback_entries
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

  def then_i_see_first_page_of_feedback_with_pagination
    expect(page).to have_selector("table tbody tr", count: 10)
    expect(page).to have_link("Next")
  end

  def then_i_see_second_page_of_feedback_with_pagination
    expect(page).to have_selector("table tbody tr", count: 5)
    expect(page).to have_link("Previous")
  end

  def then_i_see_truncated_feedback_with_link(feedback)
    experience_limit = 100
    expect(page).to have_content(truncate(feedback.experience, length: experience_limit))
    expect(page).to have_link("View full", href: support_feedback_path(feedback))
  end

  def when_i_click_to_view_full_feedback
    click_link "View full"
  end

  def then_i_see_the_feedback_details_page_for(feedback)
    expect(page).to have_current_path(support_feedback_path(feedback))
    expect(page).to have_content(feedback.experience)
  end

  def then_i_see_backlink_to_feedback_list
    expect(page).to have_link("All feedback responses", href: support_feedback_index_path)
  end

  def then_i_am_on_the_feedback_list_page
    visit support_feedback_index_path
  end

  def when_i_download_the_feedback_data_as_csv
    visit support_feedback_index_path(format: :csv)
  end

  alias_method :then_i_download_the_feedback_data_as_csv, :when_i_download_the_feedback_data_as_csv
end
