# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search results ordering by UK fee", :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "ordering courses by lowest UK fee" do
    given_there_are_fee_courses_with_different_uk_fees
    when_i_visit_the_find_results_page
    and_i_sort_by_lowest_uk_fee
    then_the_courses_are_ordered_by_uk_fee_ascending
  end

  scenario "salary courses appear after fee courses" do
    given_there_are_fee_and_salary_courses
    when_i_visit_the_find_results_page
    and_i_sort_by_lowest_uk_fee
    then_salary_courses_appear_after_fee_courses
  end

  scenario "courses with NULL fees appear at the bottom" do
    given_there_are_courses_with_and_without_fees
    when_i_visit_the_find_results_page
    and_i_sort_by_lowest_uk_fee
    then_courses_without_fees_appear_at_the_bottom
  end

  scenario "uses latest published enrichment for fee ordering" do
    given_there_is_a_course_with_multiple_enrichments
    when_i_visit_the_find_results_page
    and_i_sort_by_lowest_uk_fee
    then_the_latest_enrichment_fee_is_used_for_ordering
  end

  scenario "secondary sort by course name when fees are equal" do
    given_there_are_courses_with_equal_fees
    when_i_visit_the_find_results_page
    and_i_sort_by_lowest_uk_fee
    then_courses_are_sorted_by_name_within_equal_fees
  end

  scenario "filtering to salary courses reverts to course name ordering" do
    given_there_are_fee_and_salary_courses_for_filtering
    when_i_visit_the_find_results_page
    and_i_sort_by_lowest_uk_fee
    and_i_filter_by_salary
    then_salary_courses_are_ordered_by_course_name
  end

  def given_there_are_fee_courses_with_different_uk_fees
    provider = create(:provider, provider_name: "Test Provider")

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Expensive Course",
           course_code: "EXP1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000)])

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Cheap Course",
           course_code: "CHP1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 1000)])

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Mid Course",
           course_code: "MID1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)])
  end

  def given_there_are_fee_and_salary_courses
    provider = create(:provider, provider_name: "Test Provider")

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Fee Course",
           course_code: "FEE1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000)])

    create(:course, :published, :with_full_time_sites, :salary,
           provider:,
           name: "Salary Course",
           course_code: "SAL1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 100)])
  end

  def given_there_are_courses_with_and_without_fees
    provider = create(:provider, provider_name: "Test Provider")

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Course With Fee",
           course_code: "FEE1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)])

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Course Without Fee",
           course_code: "NUL1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: nil)])
  end

  def given_there_is_a_course_with_multiple_enrichments
    provider = create(:provider, provider_name: "Test Provider")

    course_with_multiple_enrichments = create(:course, :with_full_time_sites,
                                              provider:,
                                              name: "Updated Fee Course",
                                              course_code: "UPD1")

    create(:course_enrichment, :published,
           course: course_with_multiple_enrichments,
           fee_uk_eu: 9000,
           last_published_timestamp_utc: 10.days.ago)

    create(:course_enrichment, :published,
           course: course_with_multiple_enrichments,
           fee_uk_eu: 1000,
           last_published_timestamp_utc: 1.day.ago)

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Standard Course",
           course_code: "STD1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)])
  end

  def given_there_are_courses_with_equal_fees
    provider_a = create(:provider, provider_name: "AAA Provider")
    provider_b = create(:provider, provider_name: "BBB Provider")

    create(:course, :published, :with_full_time_sites,
           provider: provider_b,
           name: "Same Fee Course B",
           course_code: "SFB1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)])

    create(:course, :published, :with_full_time_sites,
           provider: provider_a,
           name: "Same Fee Course A",
           course_code: "SFA1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)])
  end

  def given_there_are_fee_and_salary_courses_for_filtering
    provider = create(:provider, provider_name: "Test Provider")

    create(:course, :published, :with_full_time_sites,
           provider:,
           name: "Fee Course",
           course_code: "FEE1",
           enrichments: [build(:course_enrichment, :published, fee_uk_eu: 1000)])

    create(:course, :published, :with_full_time_sites, :salary,
           provider:,
           name: "Zebra Salary",
           course_code: "SAL2",
           enrichments: [build(:course_enrichment, :published)])

    create(:course, :published, :with_full_time_sites, :salary,
           provider:,
           name: "Alpha Salary",
           course_code: "SAL1",
           enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_find_results_page
    visit find_results_path
  end

  def and_i_sort_by_lowest_uk_fee
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Lowest fee for UK citizens", visible: :hidden
    click_link_or_button "Apply filters"
  end

  def and_i_filter_by_salary
    page.find("h3", text: "Filter by\nFee or salary").click
    check "Salary", visible: :all
    click_link_or_button "Apply filters", match: :first
  end

  def then_the_courses_are_ordered_by_uk_fee_ascending
    expect(result_titles).to eq([
      "Test Provider Cheap Course (CHP1)",
      "Test Provider Mid Course (MID1)",
      "Test Provider Expensive Course (EXP1)",
    ])
  end

  def then_salary_courses_appear_after_fee_courses
    expect(result_titles).to eq([
      "Test Provider Fee Course (FEE1)",
      "Test Provider Salary Course (SAL1)",
    ])
  end

  def then_courses_without_fees_appear_at_the_bottom
    expect(result_titles).to eq([
      "Test Provider Course With Fee (FEE1)",
      "Test Provider Course Without Fee (NUL1)",
    ])
  end

  def then_the_latest_enrichment_fee_is_used_for_ordering
    expect(result_titles).to eq([
      "Test Provider Updated Fee Course (UPD1)",
      "Test Provider Standard Course (STD1)",
    ])
  end

  def then_courses_are_sorted_by_name_within_equal_fees
    expect(result_titles).to eq([
      "AAA Provider Same Fee Course A (SFA1)",
      "BBB Provider Same Fee Course B (SFB1)",
    ])
  end

  def then_salary_courses_are_ordered_by_course_name
    expect(result_titles).to eq([
      "Test Provider Alpha Salary (SAL1)",
      "Test Provider Zebra Salary (SAL2)",
    ])
  end

  def result_titles
    page.all(".govuk-summary-card__title", minimum: 1).map { |element| element.text.split("\n").join(" ") }
  end
end
