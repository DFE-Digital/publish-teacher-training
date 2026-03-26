# frozen_string_literal: true

require "rails_helper"
require_relative "ordering_helper"

RSpec.describe "Search results ordering by newest course", :js, service: :find do
  include OrderingHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "ordering by newest course" do
    given_there_are_courses_with_different_published_dates
    when_i_visit_the_find_results_page
    and_i_sort_by_newest_course
    then_the_courses_are_ordered_by_newest_first
  end

  scenario "secondary sort by provider name when published dates are equal" do
    given_there_are_courses_with_same_published_date
    when_i_visit_the_find_results_page
    and_i_sort_by_newest_course
    then_courses_are_sorted_by_provider_within_same_published_date
  end

  def given_there_are_courses_with_different_published_dates
    provider = create(:provider, provider_name: "Test Provider")

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Old Course",
           course_code: "OLD1",
           enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 3.days.ago)])

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "New Course",
           course_code: "NEW1",
           enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.day.ago)])

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Mid Course",
           course_code: "MID1",
           enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 2.days.ago)])
  end

  def given_there_are_courses_with_same_published_date
    alpha_provider = create(:provider, provider_name: "Alpha Provider")
    zeta_provider = create(:provider, provider_name: "Zeta Provider")
    same_time = 1.day.ago

    create(:course, :published, :with_full_time_sites,
           provider: zeta_provider,
           name: "Zeta Course",
           course_code: "ZET1",
           enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: same_time)])

    create(:course, :published, :with_full_time_sites,
           provider: alpha_provider,
           name: "Alpha Course",
           course_code: "ALP1",
           enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: same_time)])
  end

  def when_i_visit_the_find_results_page
    visit find_results_path
  end

  def and_i_sort_by_newest_course
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Newest course", visible: :hidden
    click_link_or_button "Apply filters"
  end

  def then_the_courses_are_ordered_by_newest_first
    expect(result_titles).to eq([
      "Test Provider New Course (NEW1)",
      "Test Provider Mid Course (MID1)",
      "Test Provider Old Course (OLD1)",
    ])
  end

  def then_courses_are_sorted_by_provider_within_same_published_date
    expect(result_titles).to eq([
      "Alpha Provider Alpha Course (ALP1)",
      "Zeta Provider Zeta Course (ZET1)",
    ])
  end
end
