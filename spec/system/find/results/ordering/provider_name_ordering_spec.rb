# frozen_string_literal: true

require "rails_helper"
require_relative "ordering_helper"

RSpec.describe "Search results ordering by provider name", :js, service: :find do
  include OrderingHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "ordering providers A to Z" do
    given_there_are_courses_from_different_providers
    when_i_visit_the_find_results_page
    and_i_sort_by_provider_name_a_to_z
    then_the_courses_are_ordered_by_provider_name_ascending
  end

  scenario "secondary sort by course name when provider names are equal" do
    given_there_are_multiple_courses_from_same_provider
    when_i_visit_the_find_results_page
    and_i_sort_by_provider_name_a_to_z
    then_courses_are_sorted_by_name_within_same_provider
  end

  scenario "ordering courses by provider name when location is present" do
    given_there_are_courses_from_different_providers_at_different_locations
    when_i_visit_the_find_results_page_with_london_location
    and_i_sort_by_provider_name_a_to_z
    then_the_courses_are_ordered_by_provider_name_not_distance
  end

  def given_there_are_courses_from_different_providers
    provider_c = create(:provider, provider_name: "Cambridge University")
    provider_a = create(:provider, provider_name: "Aston University")
    provider_b = create(:provider, provider_name: "Bristol University")

    create(:course, :published, :with_full_time_sites, provider: provider_c, name: "Art", course_code: "ART3")
    create(:course, :published, :with_full_time_sites, provider: provider_a, name: "Art", course_code: "ART1")
    create(:course, :published, :with_full_time_sites, provider: provider_b, name: "Art", course_code: "ART2")
  end

  def given_there_are_multiple_courses_from_same_provider
    provider = create(:provider, provider_name: "Test University")

    create(:course, :published, :with_full_time_sites, provider:, name: "Computing", course_code: "CMP1")
    create(:course, :published, :with_full_time_sites, provider:, name: "Art", course_code: "ART1")
    create(:course, :published, :with_full_time_sites, provider:, name: "Biology", course_code: "BIO1")
  end

  def when_i_visit_the_find_results_page
    visit find_results_path
  end

  def and_i_sort_by_provider_name_a_to_z
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Training provider (a to z)", visible: :hidden
    click_link_or_button "Apply filters"
  end

  def then_the_courses_are_ordered_by_provider_name_ascending
    expect(result_titles).to eq([
      "Aston University Art (ART1)",
      "Bristol University Art (ART2)",
      "Cambridge University Art (ART3)",
    ])
  end

  def then_courses_are_sorted_by_name_within_same_provider
    expect(result_titles).to eq([
      "Test University Art (ART1)",
      "Test University Biology (BIO1)",
      "Test University Computing (CMP1)",
    ])
  end

  def given_there_are_courses_from_different_providers_at_different_locations
    london = build(:location, :london)
    romford = build(:location, :romford)

    # Closer to London but later alphabetically
    provider_z = create(:provider, provider_name: "Zenith University")
    create(:course, :published,
           provider: provider_z,
           name: "Art",
           course_code: "ART1",
           site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))])

    # Further from London but earlier alphabetically
    provider_a = create(:provider, provider_name: "Aston University")
    create(:course, :published,
           provider: provider_a,
           name: "Art",
           course_code: "ART2",
           site_statuses: [create(:site_status, :findable, site: create(:site, latitude: romford.latitude, longitude: romford.longitude))])
  end

  def then_the_courses_are_ordered_by_provider_name_not_distance
    expect(result_titles).to eq([
      "Aston University Art (ART2)",
      "Zenith University Art (ART1)",
    ])
  end
end
