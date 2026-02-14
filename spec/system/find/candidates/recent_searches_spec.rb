# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Recent searches", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
  end

  scenario "Navigation shows Recent searches link when authenticated" do
    when_i_sign_in
    then_i_see_recent_searches_in_nav
  end

  scenario "Navigation does not show Recent searches link when signed out" do
    when_i_visit_the_homepage
    then_i_do_not_see_recent_searches_in_nav
  end

  scenario "Unauthenticated user is redirected when visiting recent searches" do
    visit find_candidate_recent_searches_path
    then_i_am_prompted_to_sign_in
  end

  scenario "Empty state is shown when there are no recent searches" do
    when_i_sign_in
    when_i_visit_recent_searches
    then_i_see_empty_state
    then_i_do_not_see_clear_all_button
  end

  scenario "Recent searches are displayed with summary cards" do
    when_i_sign_in
    and_i_have_recent_searches
    when_i_visit_recent_searches

    then_i_see_my_recent_searches
    then_i_see_clear_all_button
  end

  scenario "Searches are ordered newest first" do
    when_i_sign_in
    and_i_have_searches_with_different_timestamps
    when_i_visit_recent_searches

    then_i_see_newest_search_first
  end

  scenario "At most 10 searches are displayed" do
    when_i_sign_in
    and_i_have_12_recent_searches
    when_i_visit_recent_searches

    then_i_see_exactly_10_search_cards
  end

  scenario "Summary card shows filter tags" do
    when_i_sign_in
    and_i_have_a_search_with_many_filters
    when_i_visit_recent_searches

    then_i_see_filter_tags
  end

  scenario "Search again link navigates to results with filters" do
    when_i_sign_in
    and_i_have_a_search_with_subjects
    when_i_visit_recent_searches
    when_i_click_search_again

    then_i_am_on_results_page_with_filters
  end

  scenario "Clear all discards searches and shows undo banner" do
    when_i_sign_in
    and_i_have_recent_searches
    when_i_visit_recent_searches
    when_i_click_clear_all

    then_i_see_cleared_success_banner
    then_i_see_empty_state
  end

  scenario "Undo restores cleared searches" do
    when_i_sign_in
    and_i_have_recent_searches
    when_i_visit_recent_searches
    when_i_click_clear_all
    when_i_click_undo

    then_i_see_my_recent_searches
  end

  scenario "Clear all does not affect another candidate's searches" do
    when_i_sign_in
    and_i_have_recent_searches
    and_another_candidate_has_searches
    when_i_visit_recent_searches
    when_i_click_clear_all

    then_the_other_candidate_still_has_searches
  end

  scenario "Stale searches are discarded on page load" do
    when_i_sign_in
    and_i_have_a_stale_search
    and_i_have_a_fresh_search
    when_i_visit_recent_searches

    then_i_see_only_the_fresh_search
    then_the_stale_search_is_discarded
  end

  scenario "Recording a search via the results page" do
    given_a_published_course_exists
    when_i_sign_in
    when_i_search_with_subjects

    then_a_recent_search_is_recorded
  end

  scenario "Browsing results without filters does not record a search" do
    given_a_published_course_exists
    when_i_sign_in
    when_i_visit_results_without_filters

    then_no_recent_search_is_recorded
  end

  scenario "Searching when not authenticated does not record a search" do
    given_a_published_course_exists
    when_i_visit_results_with_subjects_unauthenticated

    then_no_recent_search_is_recorded
  end

  scenario "Duplicate search updates existing record instead of creating a new one" do
    given_a_published_course_exists
    when_i_sign_in
    when_i_search_with_subjects
    when_i_search_with_subjects

    then_only_one_recent_search_exists
  end

  scenario "CleanupRecentSearchesJob permanently deletes old discarded searches" do
    when_i_sign_in
    and_i_have_recent_searches
    when_i_visit_recent_searches
    when_i_click_clear_all

    then_the_searches_are_discarded_not_destroyed

    travel 2.days

    when_the_cleanup_job_runs

    then_the_discarded_searches_are_permanently_deleted
  end

  scenario "CleanupRecentSearchesJob preserves recently discarded searches" do
    when_i_sign_in
    and_i_have_recent_searches
    when_i_visit_recent_searches
    when_i_click_clear_all

    when_the_cleanup_job_runs

    then_the_discarded_searches_still_exist_in_database
  end

  scenario "CleanupRecentSearchesJob permanently deletes searches older than 30 days" do
    when_i_sign_in
    and_i_have_a_stale_search
    and_i_have_a_fresh_search

    when_the_cleanup_job_runs

    then_the_stale_search_is_permanently_deleted
    then_the_fresh_search_still_exists
  end

  def when_i_sign_in
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def when_i_visit_the_homepage
    visit "/"
  end

  def when_i_visit_recent_searches
    visit find_candidate_recent_searches_path
  end

  def candidate
    Candidate.first
  end

  def then_i_see_recent_searches_in_nav
    expect(page).to have_link("Recent searches")
  end

  def then_i_do_not_see_recent_searches_in_nav
    expect(page).not_to have_link("Recent searches")
  end

  def then_i_am_prompted_to_sign_in
    expect(page).to have_current_path(find_root_path)
  end

  def then_i_see_empty_state
    expect(page).to have_content("No recent searches")
    expect(page).to have_link("Find courses")
  end

  def then_i_do_not_see_clear_all_button
    expect(page).not_to have_button("Clear all recent searches")
  end

  def then_i_see_clear_all_button
    expect(page).to have_button("Clear all recent searches")
  end

  def and_i_have_recent_searches
    create_subject!("C1", "Biology")
    create_subject!("F1", "Chemistry")

    @search1 = create(
      :recent_search,
      candidate:,
      subjects: %w[C1],
      search_attributes: { "level" => "secondary" },
      updated_at: 1.hour.ago,
    )
    @search2 = create(
      :recent_search,
      candidate:,
      subjects: %w[F1],
      search_attributes: { "can_sponsor_visa" => "true" },
      updated_at: 2.hours.ago,
    )
  end

  def and_i_have_searches_with_different_timestamps
    create_subject!("C1", "Biology")
    create_subject!("F1", "Chemistry")

    @old_search = create(
      :recent_search,
      candidate:,
      subjects: %w[C1],
      updated_at: 2.days.ago,
    )
    @new_search = create(
      :recent_search,
      candidate:,
      subjects: %w[F1],
      updated_at: 1.minute.ago,
    )
  end

  def and_i_have_12_recent_searches
    12.times do |i|
      create(
        :recent_search,
        candidate:,
        subjects: ["S#{i}"],
        updated_at: i.hours.ago,
      )
    end
  end

  def and_i_have_a_search_with_many_filters
    create_subject!("C1", "Biology")

    create(
      :recent_search,
      candidate:,
      subjects: %w[C1],
      radius: 15,
      search_attributes: {
        "location" => "Manchester",
        "can_sponsor_visa" => "true",
        "funding" => %w[salary],
        "send_courses" => "true",
        "level" => "secondary",
      },
    )
  end

  def and_i_have_a_search_with_subjects
    create_subject!("C1", "Biology")

    @subject_search = create(
      :recent_search,
      candidate:,
      subjects: %w[C1],
      search_attributes: { "level" => "secondary" },
    )
  end

  def and_another_candidate_has_searches
    @other_candidate = create(:candidate, email_address: "other@example.com")
    @other_search = create(:recent_search, candidate: @other_candidate)
  end

  def and_i_have_a_stale_search
    @stale_search = create(:recent_search, candidate:, subjects: %w[STALE], updated_at: 31.days.ago)
  end

  def and_i_have_a_fresh_search
    create_subject!("C1", "Biology") unless Subject.exists?(subject_code: "C1")

    @fresh_search = create(
      :recent_search,
      candidate:,
      subjects: %w[C1],
      search_attributes: { "level" => "secondary" },
      updated_at: 1.day.ago,
    )
  end

  def then_i_see_my_recent_searches
    expect(page).to have_content("Biology")
  end

  def then_i_see_newest_search_first
    cards = all(".govuk-summary-card")
    expect(cards.length).to eq(2)
    # The newest (Chemistry/F1) should appear before the oldest (Biology/C1)
    expect(cards[0].text).to include("Chemistry")
    expect(cards[1].text).to include("Biology")
  end

  def then_i_see_exactly_10_search_cards
    cards = all(".govuk-summary-card")
    expect(cards.length).to eq(10)
  end

  def then_i_see_filter_tags
    expect(page).to have_content("Biology")
    expect(page).to have_content("Within 15 miles of Manchester")
    expect(page).to have_content("Visa sponsorship")
    expect(page).to have_content("Salary")
    expect(page).to have_content("SEND courses")
    expect(page).to have_content("Secondary")
  end

  def when_i_click_search_again
    click_link_or_button "Search again"
  end

  def then_i_am_on_results_page_with_filters
    expect(page).to have_current_path(/\/results/)
    uri = URI.parse(current_url)
    params = Rack::Utils.parse_nested_query(uri.query)
    expect(params["subjects"]).to include("C1")
  end

  def when_i_click_clear_all
    click_link_or_button "Clear all recent searches"
  end

  def when_i_click_undo
    click_link_or_button "Undo"
  end

  def then_i_see_cleared_success_banner
    expect(page).to have_content("Recent searches cleared")
    expect(page).to have_content("All your recent searches have been deleted.")
  end

  def then_the_other_candidate_still_has_searches
    expect(RecentSearch.kept.where(candidate: @other_candidate).count).to eq(1)
  end

  def then_i_see_only_the_fresh_search
    expect(page).to have_content("Biology")
    cards = all(".govuk-summary-card")
    expect(cards.length).to eq(1)
  end

  def then_the_stale_search_is_discarded
    expect(@stale_search.reload).to be_discarded
  end

  def given_a_published_course_exists
    @subject = create_subject!("C1", "Biology")
    @course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :published,
      :open,
      name: "Biology",
      course_code: "BIO1",
      provider: build(:provider, provider_name: "Test Provider", provider_code: "TP1"),
      subjects: [@subject],
    )
  end

  def when_i_search_with_subjects
    visit find_results_path(subjects: %w[C1])
  end

  def when_i_visit_results_without_filters
    visit find_results_path
  end

  def when_i_visit_results_with_subjects_unauthenticated
    visit find_results_path(subjects: %w[C1])
  end

  def then_a_recent_search_is_recorded
    expect(candidate.recent_searches.count).to eq(1)
    expect(candidate.recent_searches.first.subjects).to include("C1")
  end

  def then_no_recent_search_is_recorded
    expect(RecentSearch.count).to eq(0)
  end

  def then_only_one_recent_search_exists
    expect(candidate.recent_searches.count).to eq(1)
  end

  def when_the_cleanup_job_runs
    CleanupRecentSearchesJob.perform_now
  end

  def then_the_searches_are_discarded_not_destroyed
    expect(RecentSearch.with_discarded.where(candidate:).discarded.count).to be >= 1
  end

  def then_the_discarded_searches_are_permanently_deleted
    expect(RecentSearch.with_discarded.where(candidate:).count).to eq(0)
  end

  def then_the_discarded_searches_still_exist_in_database
    expect(RecentSearch.with_discarded.where(candidate:).discarded.count).to be >= 1
  end

  def then_the_stale_search_is_permanently_deleted
    expect(RecentSearch.with_discarded.find_by(id: @stale_search.id)).to be_nil
  end

  def then_the_fresh_search_still_exists
    expect(RecentSearch.find_by(id: @fresh_search.id)).to be_present
  end

  def create_subject!(code, name)
    return Subject.find_by(subject_code: code) if Subject.exists?(subject_code: code)

    subject_area = SubjectArea.find_or_create_by!(typename: "SecondarySubject", name: "Secondary")
    Subject.create!(subject_code: code, subject_name: name, type: "SecondarySubject", subject_area:)
  end
end
