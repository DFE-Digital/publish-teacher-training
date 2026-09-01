# frozen_string_literal: true

require "rails_helper"
require_relative "ordering_helper"

# The sibling ordering specs cover these sorts over the legacy course_site -> site
# path. With :course_publishing_uses_new_school_model on, the distance a location
# search annotates each course with comes from a derived table instead, while each
# of these sorts adds a GROUP BY of its own. The two have to agree: when they did
# not, every one of these searches returned a 500 instead of results, and a course
# matching two of the chosen subjects was listed twice.
RSpec.describe "Search results ordering with a location on the new school model", :js, service: :find do
  include OrderingHelper

  before do
    FeatureFlag.activate(:course_publishing_uses_new_school_model)
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

  scenario "ordering courses by lowest UK fee when a location is present" do
    given_there_are_courses_at_different_locations_with_different_uk_fees
    when_i_visit_the_find_results_page_with_london_location
    and_i_sort_by_lowest_uk_fee
    then_the_courses_are_ordered_by_uk_fee_not_distance
  end

  scenario "ordering courses by lowest international fee when a location is present" do
    given_there_are_courses_at_different_locations_with_different_international_fees
    when_i_visit_the_find_results_page_with_london_location
    and_i_sort_by_lowest_international_fee
    then_the_courses_are_ordered_by_international_fee_not_distance
  end

  scenario "ordering courses by newest course when a location is present" do
    given_there_are_courses_at_different_locations_published_at_different_times
    when_i_visit_the_find_results_page_with_london_location
    and_i_sort_by_newest_course
    then_the_courses_are_ordered_by_newest_first_not_distance
  end

  scenario "a course matching several of the chosen subjects is listed once" do
    given_there_is_a_nearby_course_teaching_physics_and_biology
    when_i_search_that_location_for_physics_and_biology
    then_the_course_is_listed_once
  end

  # Teaches `course` at `location` through the canonical course_school -> gias_school
  # model, the only location source the flag leaves in play.
  def teach_at(course, location)
    create(
      :course_school,
      course:,
      gias_school: create(:gias_school, latitude: location.latitude, longitude: location.longitude),
    )
    course
  end

  def given_there_are_courses_at_different_locations_with_different_uk_fees
    provider = create(:provider, provider_name: "Test Provider")

    # Closer to London but more expensive
    teach_at(
      create(:course, :published, provider:, name: "Expensive Course", course_code: "EXP1",
                                  enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000)]),
      build(:location, :london),
    )

    # Further from London but cheaper
    teach_at(
      create(:course, :published, provider:, name: "Cheap Course", course_code: "CHP1",
                                  enrichments: [build(:course_enrichment, :published, fee_uk_eu: 1000)]),
      build(:location, :romford),
    )
  end

  def given_there_are_courses_at_different_locations_with_different_international_fees
    provider = create(:provider, provider_name: "Test Provider")

    teach_at(
      create(:course, :published, provider:, name: "Expensive Course", course_code: "EXP1",
                                  enrichments: [build(:course_enrichment, :published, fee_international: 18_000)]),
      build(:location, :london),
    )

    teach_at(
      create(:course, :published, provider:, name: "Cheap Course", course_code: "CHP1",
                                  enrichments: [build(:course_enrichment, :published, fee_international: 12_000)]),
      build(:location, :romford),
    )
  end

  def given_there_are_courses_at_different_locations_published_at_different_times
    provider = create(:provider, provider_name: "Test Provider")

    # Closer to London but published longer ago
    teach_at(
      create(:course, :published, provider:, name: "Old Course", course_code: "OLD1",
                                  enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 5.days.ago)]),
      build(:location, :london),
    )

    teach_at(
      create(:course, :published, provider:, name: "Recent Course", course_code: "REC1",
                                  enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.day.ago)]),
      build(:location, :romford),
    )
  end

  def given_there_is_a_nearby_course_teaching_physics_and_biology
    @physics = find_or_create(:secondary_subject, :physics)
    @biology = find_or_create(:secondary_subject, :biology)

    teach_at(
      create(:course, :published, :secondary,
             provider: create(:provider, provider_name: "Test Provider"),
             name: "Physics and Biology", course_code: "PHB1",
             subjects: [@physics, @biology]),
      build(:location, :london),
    )
  end

  def when_i_search_that_location_for_physics_and_biology
    stub_london_location_search
    visit find_results_path(location: "London, UK", subjects: [@physics.subject_code, @biology.subject_code])
  end

  def then_the_courses_are_ordered_by_uk_fee_not_distance
    expect(result_titles).to eq([
      "Test Provider Cheap Course (CHP1)",
      "Test Provider Expensive Course (EXP1)",
    ])
  end

  def then_the_courses_are_ordered_by_international_fee_not_distance
    expect(result_titles).to eq([
      "Test Provider Cheap Course (CHP1)",
      "Test Provider Expensive Course (EXP1)",
    ])
  end

  def then_the_courses_are_ordered_by_newest_first_not_distance
    expect(result_titles).to eq([
      "Test Provider Recent Course (REC1)",
      "Test Provider Old Course (OLD1)",
    ])
  end

  def then_the_course_is_listed_once
    expect(result_titles).to eq(["Test Provider Physics and Biology (PHB1)"])
  end

  def and_i_sort_by_lowest_uk_fee
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Lowest fee for UK citizens", visible: :hidden
    click_link_or_button "Apply filters"
  end

  def and_i_sort_by_lowest_international_fee
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Lowest fee for non-UK citizens", visible: :hidden
    click_link_or_button "Apply filters"
  end

  def and_i_sort_by_newest_course
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Newest course", visible: :hidden
    click_link_or_button "Apply filters"
  end
end
