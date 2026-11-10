# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Provider history" do
  let(:user) { create(:user, :admin, first_name: "Jade", last_name: "Clare") }
  let(:provider) { create(:provider, :scitt, provider_name: "2Schools Consortium", provider_code: "T92") }
  let(:course) { create(:course, provider:, name: "Primary with English", course_code: "A123") }

  before do
    given_i_am_authenticated(user:)
  end

  scenario "I can view the provider history of changes" do
    and_there_are_history_entries
    when_i_visit_the_provider_courses_page
    and_i_click_the_history_tab
    then_i_see_the_history_table
    and_course_links_point_to_publish
    and_admin_users_are_tagged
  end

  scenario "I can see publishing status changes" do
    and_there_is_a_publishing_status_change
    when_i_visit_the_history_page
    then_i_see_the_publishing_status_change
  end

  scenario "I see an empty state when there are no changes" do
    when_i_visit_the_history_page
    then_i_see_the_empty_state
  end

  scenario "I can move between history pages" do
    stub_const("Support::Providers::HistoryController::PER_PAGE", 2)
    and_there_are_three_history_entries
    when_i_visit_the_history_page
    then_i_see_the_first_page_of_history
    when_i_go_to_the_next_history_page
    then_i_see_the_second_page_of_history
  end

private

  def and_there_are_history_entries
    Audited::Audit.create!(
      auditable: provider,
      user:,
      action: "update",
      audited_changes: { "provider_name" => ["2Schools Consortium", "3Schools Consortium"] },
      version: 1,
      created_at: 2.days.ago,
    )
    Audited::Audit.create!(
      auditable: course,
      user:,
      action: "update",
      audited_changes: { "name" => ["Primary", "Primary with English"] },
      version: 1,
      created_at: 1.day.ago,
    )
    Audited::Audit.create!(
      auditable: course,
      user:,
      action: "update",
      audited_changes: { "application_status" => %w[open closed] },
      version: 1,
      created_at: Time.zone.now,
    )
  end

  def and_there_is_a_publishing_status_change
    enrichment = create(:course_enrichment, :published, course:)
    Audited::Audit.create!(
      auditable: enrichment,
      associated: course,
      user:,
      action: "update",
      audited_changes: { "status" => %w[rolled_over published] },
      version: 1,
    )
  end

  def and_there_are_three_history_entries
    Audited::Audit.create!(
      auditable: provider,
      user:,
      action: "update",
      audited_changes: { "provider_name" => %w[Alpha Beta] },
      version: 1,
      created_at: 3.days.ago,
    )
    Audited::Audit.create!(
      auditable: provider,
      user:,
      action: "update",
      audited_changes: { "provider_name" => %w[Beta Gamma] },
      version: 1,
      created_at: 2.days.ago,
    )
    Audited::Audit.create!(
      auditable: provider,
      user:,
      action: "update",
      audited_changes: { "provider_name" => %w[Gamma Delta] },
      version: 1,
      created_at: 1.day.ago,
    )
  end

  def when_i_visit_the_provider_courses_page
    visit support_recruitment_cycle_provider_courses_path(
      provider.recruitment_cycle_year,
      provider,
    )
  end

  def when_i_visit_the_history_page
    visit support_recruitment_cycle_provider_history_index_path(
      provider.recruitment_cycle_year,
      provider,
    )
  end

  def and_i_click_the_history_tab
    click_link_or_button "History"
  end

  def when_i_go_to_the_next_history_page
    click_link_or_button "Next page"
  end

  def then_i_see_the_history_table
    expect(page).to have_css(".app-tab-navigation__link[aria-current='page']", text: "History")
    expect(page).to have_content("Change")
    expect(page).to have_content("Time")
    expect(page).to have_content("User")
    expect(page).to have_content("Provider name changed from")
    expect(page).to have_content("3Schools Consortium")
    expect(page).to have_content("Course name changed from")
    expect(page).to have_content("Applications status changed from")
    expect(page).to have_css(".govuk-tag", text: "Open")
    expect(page).to have_css(".govuk-tag", text: "Closed")
  end

  def then_i_see_the_publishing_status_change
    expect(page).to have_content("Publishing status changed from")
    expect(page).to have_css(".govuk-tag", text: "Rolled over")
    expect(page).to have_css(".govuk-tag", text: "Published")
    expect(page).to have_link(course.name_and_code)
  end

  def then_i_see_the_empty_state
    expect(page).to have_content("No changes have been recorded for this provider.")
  end

  def then_i_see_the_first_page_of_history
    expect(page).to have_content("Gamma")
    expect(page).to have_content("Delta")
    expect(page).to have_content("Beta")
    expect(page).to have_link("Next page")
  end

  def then_i_see_the_second_page_of_history
    expect(page).to have_content("Alpha")
    expect(page).to have_content("Beta")
    expect(page).to have_no_content("Delta")
  end

  def and_course_links_point_to_publish
    expect(page).to have_link(
      course.name_and_code,
      href: publish_provider_recruitment_cycle_course_url(
        provider.provider_code,
        provider.recruitment_cycle_year,
        course.course_code,
      ),
    )
  end

  def and_admin_users_are_tagged
    expect(page).to have_content("Jade Clare")
    expect(page).to have_css(".govuk-tag", text: "Admin")
  end
end
