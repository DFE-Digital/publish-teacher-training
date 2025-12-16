# frozen_string_literal: true

require "rails_helper"
require_relative "ordering_helper"

RSpec.describe "Search results ordering by course name", :js, service: :find do
  include OrderingHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "default ordering is by course name A to Z" do
    given_there_are_courses_with_different_names
    when_i_visit_the_find_results_page
    then_the_courses_are_ordered_by_name_ascending
  end

  scenario "explicitly sorting by course name A to Z" do
    given_there_are_courses_with_different_names
    when_i_visit_the_find_results_page
    and_i_sort_by_course_name_a_to_z
    then_the_courses_are_ordered_by_name_ascending
  end

  scenario "secondary sort by provider name when course names are equal" do
    given_there_are_courses_with_same_name_different_providers
    when_i_visit_the_find_results_page
    then_courses_are_sorted_by_provider_within_same_name
  end

  scenario "tertiary sort by course code when name and provider are equal" do
    given_there_are_courses_with_same_name_and_provider
    when_i_visit_the_find_results_page
    then_courses_are_sorted_by_code_within_same_name_and_provider
  end

  scenario "ordering courses by name when location is present" do
    given_there_are_courses_at_different_locations
    when_i_visit_the_find_results_page_with_london_location
    and_i_sort_by_course_name_a_to_z
    then_the_courses_are_ordered_by_name_not_distance
  end

  def given_there_are_courses_with_different_names
    provider = create(:provider, provider_name: "Test Provider")

    create(:course, :published, :with_full_time_sites, provider:, name: "Computing", course_code: "CMP1")
    create(:course, :published, :with_full_time_sites, provider:, name: "Art", course_code: "ART1")
    create(:course, :published, :with_full_time_sites, provider:, name: "Biology", course_code: "BIO1")
  end

  def given_there_are_courses_with_same_name_different_providers
    provider_a = create(:provider, provider_name: "AAA University")
    provider_b = create(:provider, provider_name: "BBB University")

    create(:course, :published, :with_full_time_sites, provider: provider_b, name: "Art", course_code: "ART2")
    create(:course, :published, :with_full_time_sites, provider: provider_a, name: "Art", course_code: "ART1")
  end

  def given_there_are_courses_with_same_name_and_provider
    provider = create(:provider, provider_name: "Test Provider")

    create(:course, :published, :with_full_time_sites, provider:, name: "Art", course_code: "ZZZ1")
    create(:course, :published, :with_full_time_sites, provider:, name: "Art", course_code: "AAA1")
  end

  def when_i_visit_the_find_results_page
    visit find_results_path
  end

  def and_i_sort_by_course_name_a_to_z
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Course name (a to z)", visible: :hidden
    click_link_or_button "Apply filters"
  end

  def then_the_courses_are_ordered_by_name_ascending
    expect(result_titles).to eq([
      "Test Provider Art (ART1)",
      "Test Provider Biology (BIO1)",
      "Test Provider Computing (CMP1)",
    ])
  end

  def then_courses_are_sorted_by_provider_within_same_name
    expect(result_titles).to eq([
      "AAA University Art (ART1)",
      "BBB University Art (ART2)",
    ])
  end

  def then_courses_are_sorted_by_code_within_same_name_and_provider
    expect(result_titles).to eq([
      "Test Provider Art (AAA1)",
      "Test Provider Art (ZZZ1)",
    ])
  end

  def given_there_are_courses_at_different_locations
    london = build(:location, :london)
    romford = build(:location, :romford)

    provider = create(:provider, provider_name: "Test Provider")

    # Closer to London but later alphabetically
    create(:course, :published,
           provider:,
           name: "Zoology",
           course_code: "ZOO1",
           site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))])

    # Further from London but earlier alphabetically
    create(:course, :published,
           provider:,
           name: "Art",
           course_code: "ART1",
           site_statuses: [create(:site_status, :findable, site: create(:site, latitude: romford.latitude, longitude: romford.longitude))])
  end

  def then_the_courses_are_ordered_by_name_not_distance
    expect(result_titles).to eq([
      "Test Provider Art (ART1)",
      "Test Provider Zoology (ZOO1)",
    ])
  end
end
