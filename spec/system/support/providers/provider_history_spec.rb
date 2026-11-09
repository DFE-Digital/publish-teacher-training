# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Provider history" do
  let(:user) { create(:user, :admin, first_name: "Jade", last_name: "Clare") }
  let(:provider) { create(:provider, :scitt, provider_name: "2Schools Consortium", provider_code: "T92") }
  let(:course) { create(:course, provider:, name: "Primary with English", course_code: "A123") }

  before do
    given_i_am_authenticated(user:)
    and_there_are_history_entries
  end

  scenario "I can view the provider history of changes" do
    when_i_visit_the_provider_courses_page
    and_i_click_the_history_tab
    then_i_see_the_history_table
    and_course_links_point_to_publish
    and_admin_users_are_tagged
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

  def when_i_visit_the_provider_courses_page
    visit support_recruitment_cycle_provider_courses_path(
      provider.recruitment_cycle_year,
      provider,
    )
  end

  def and_i_click_the_history_tab
    click_link_or_button "History"
  end

  def then_i_see_the_history_table
    expect(page).to have_css(".app-tab-navigation__link[aria-current='page']", text: "History")
    expect(page).to have_content("Change")
    expect(page).to have_content("Time")
    expect(page).to have_content("User")
    expect(page).to have_content("Provider name changed from")
    expect(page).to have_content("3Schools Consortium")
    expect(page).to have_content("Course name changed from")
    expect(page).to have_content("Status changed from")
    expect(page).to have_css(".govuk-tag", text: "Open")
    expect(page).to have_css(".govuk-tag", text: "Closed")
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
