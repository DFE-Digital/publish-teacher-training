# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Salaried course callout on results page", service: :find do
  include Rails.application.routes.url_helpers

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_is_a_salaried_physics_course_with_a_bursary
  end

  scenario "filtering by salary and a subject with a bursary shows the callout above the first result" do
    when_i_search_for_salaried_physics_courses
    then_i_see_the_callout_above_the_first_result

    when_i_click_the_bursaries_link
    then_the_click_is_tracked
    and_i_am_taken_to_get_into_teaching
  end

  scenario "filtering by a subject with a bursary without salary or apprenticeship hides the callout" do
    when_i_search_for_fee_paying_physics_courses
    then_i_do_not_see_the_callout
  end

  def given_there_is_a_salaried_physics_course_with_a_bursary
    physics = find_or_create(:secondary_subject, :physics)
    physics.financial_incentive.update!(bursary_amount: "29000", scholarship: nil)

    create(:course, :open, :with_full_time_sites, :secondary, funding: "salary", name: "Physics", subjects: [physics])
    create(:course, :open, :with_full_time_sites, :secondary, funding: "fee", name: "Physics", subjects: [physics])
  end

  def when_i_search_for_salaried_physics_courses
    visit find_results_path(funding: %w[salary], subjects: %w[F3])
  end

  def when_i_search_for_fee_paying_physics_courses
    visit find_results_path(funding: %w[fee], subjects: %w[F3])
  end

  def then_i_see_the_callout_above_the_first_result
    expect(page).to have_css(".app-callout + .app-search-results", count: 1)
    expect(page).to have_css(".app-callout h2", text: "Is a salaried course right for me?")
  end

  def then_i_do_not_see_the_callout
    expect(page).to have_css(".app-search-results")
    expect(page).to have_no_text("Is a salaried course right for me?")
  end

  def when_i_click_the_bursaries_link
    allow(Find::Analytics::ClickEvent).to receive(:new).and_call_original

    click_link_or_button "bursaries", exact: true
  end

  def then_the_click_is_tracked
    expect(Find::Analytics::ClickEvent).to have_received(:new).with(
      hash_including(
        utm_content: "results_salaried_course_callout_bursaries",
        url: "https://getintoteaching.education.gov.uk/funding-and-support/scholarships-and-bursaries",
      ),
    )
  end

  def and_i_am_taken_to_get_into_teaching
    expect(page.current_url).to eq("https://getintoteaching.education.gov.uk/funding-and-support/scholarships-and-bursaries")
  end
end
