# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing course information in the course list" do
  let(:provider) { create(:provider, :accredited_provider) }

  before do
    given_i_am_authenticated(user: create(:user, providers: [provider]))
  end

  scenario "the course information column shows funding, qualification, study type and start date" do
    given_a_course_with_known_information
    when_i_visit_the_courses_page
    then_i_see_the_course_information_on_separate_lines
    and_i_see_the_start_date_in_the_smaller_font
  end

  scenario "courses that differ only by start date are distinguishable" do
    given_two_courses_that_differ_only_by_start_date
    when_i_visit_the_courses_page
    then_i_see_both_start_dates
  end

  def given_a_course_with_known_information
    create(
      :course,
      provider:,
      accrediting_provider: nil,
      funding: :fee,
      qualification: :pgce_with_qts,
      study_mode: :full_time,
      start_date: Time.zone.local(2026, 9, 1),
    )
  end

  def given_two_courses_that_differ_only_by_start_date
    create(:course, provider:, accrediting_provider: nil, name: "Primary", start_date: Time.zone.local(2026, 9, 1))
    create(:course, provider:, accrediting_provider: nil, name: "Primary", start_date: Time.zone.local(2027, 1, 1))
  end

  def when_i_visit_the_courses_page
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def then_i_see_the_course_information_on_separate_lines
    within '.app-table--courses__course-information' do
      expect(page).to have_text("Fee-paying")
      expect(page).to have_text("QTS with PGCE")
      expect(page).to have_text("Full time")
      expect(page).to have_text("September 2026")
    end
  end

  def and_i_see_the_start_date_in_the_smaller_font
    expect(page).to have_css('.app-table--courses__course-information .govuk-\!-font-size-16', text: "September 2026")
  end

  def then_i_see_both_start_dates
    information = page.all('.app-table--courses__course-information').map(&:text).join(" ")
    expect(information).to include("September 2026")
    expect(information).to include("January 2027")
  end
end
