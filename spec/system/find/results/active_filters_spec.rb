require "rails_helper"
require_relative "../results_helper"
require_relative "./filtering_helper"

RSpec.describe "Courses search with active filters", :js, service: :find do
  include ResultsHelper
  include FilteringHelper

  before do
    create(:provider, provider_name: "Example University", provider_code: "DFE01")
    create(:provider, provider_name: "Another College", provider_code: "DFE02")
    stub_autocomplete_london
    stub_london_location_search
  end

  describe "displaying active filters on results page" do
    context "with all filter types applied" do
      scenario "user sees all applied filters displayed correctly" do
        given_the_user_visits_results_with_all_filters
        then_all_active_filters_are_displayed
      end

      scenario "user can remove individual filters" do
        given_the_user_visits_results_with_all_filters
        when_the_user_clicks_remove_on_fee_funding_filter
        then_fee_funding_filter_is_removed
        and_other_filters_remain
      end

      scenario "user can clear all filters at once" do
        given_the_user_visits_results_with_all_filters
        when_the_user_clicks_clear_all
        then_all_active_filters_are_cleared
        and_user_sees_only_default_state
      end
    end

    context "with invalid filter values" do
      scenario "invalid subject codes are not displayed" do
        given_the_user_visits_results_with_invalid_subjects
        then_no_active_filters_are_displayed
      end

      scenario "invalid funding options are not displayed" do
        given_the_user_visits_results_with_invalid_funding
        then_no_active_filters_are_displayed
      end

      scenario "invalid study types are not displayed" do
        given_the_user_visits_results_with_invalid_study_types
        then_no_active_filters_are_displayed
      end

      scenario "invalid qualifications are not displayed" do
        given_the_user_visits_results_with_invalid_qualifications
        then_no_active_filters_are_displayed
      end

      scenario "invalid level is not displayed" do
        given_the_user_visits_results_with_invalid_level
        then_no_active_filters_are_displayed
      end

      scenario "invalid provider code is not displayed" do
        given_the_user_visits_results_with_invalid_provider_code
        then_no_active_filters_are_displayed
      end

      scenario "mix of valid and invalid values shows only valid filters" do
        given_the_user_visits_results_with_mixed_valid_invalid_filters
        then_only_valid_filters_are_displayed
      end

      scenario "all invalid filters" do
        given_the_user_visits_results_with_invalid_filters
        then_the_active_filters_are_visible("Courses with visa sponsorship", "Courses with a SEND specialism")
      end
    end

    context "with location search" do
      scenario "location filter is displayed with remove option" do
        given_the_user_searches_for_location("London")
        then_location_filter_is_displayed("London")
      end

      scenario "radius filter is shown only when location is present" do
        given_the_user_searches_for_location_with_radius("London", "20")
        then_location_filter_is_displayed("London")
        then_the_active_filters_are_visible("London")
        when_the_user_changes_radius_to("50", location: "London")
        and_radius_filter_is_displayed("Search radius: 50 miles")
      end

      scenario "changing radius updates the active filter" do
        given_the_user_searches_for_location_with_radius("London", "20")
        when_the_user_changes_radius_to("50", location: "London")
        then_radius_filter_shows("Search radius: 50 miles")
      end

      scenario "radius filter is removed when location is cleared" do
        given_the_user_searches_for_location_with_radius("London", "20")
        when_the_user_removes_location_filter
        then_radius_filter_is_not_displayed
      end
    end

    context "with multiple values for array filters" do
      scenario "each subject is displayed as a separate removable filter" do
        given_the_user_selects_multiple_subjects("Primary", "Mathematics")
        then_primary_subject_filter_is_displayed
        and_mathematics_subject_filter_is_displayed
        and_each_can_be_removed_individually
      end

      scenario "removing one subject keeps others" do
        given_the_user_selects_multiple_subjects("Primary", "Mathematics", "English")
        then_the_active_filters_are_visible("Primary", "Mathematics", "English")
        when_the_user_removes_subject_filter("Primary")
        then_primary_filter_is_removed
        and_mathematics_and_english_filters_remain
      end

      scenario "each funding type is displayed as a separate removable filter" do
        given_the_user_selects_multiple_funding_types("fee", "salary")
        then_fee_funding_filter_is_displayed
        and_salary_funding_filter_is_displayed
        and_each_can_be_removed_individually
      end

      scenario "each study type is displayed as a separate removable filter" do
        given_the_user_selects_multiple_study_types("full_time", "part_time")
        then_full_time_filter_is_displayed
        and_part_time_filter_is_displayed
      end

      scenario "each qualification is displayed as a separate removable filter" do
        given_the_user_selects_multiple_qualifications("qts", "qts_with_pgce_or_pgde")
        then_qts_filter_is_displayed
        and_qts_with_pgce_or_pgde_filter_is_displayed
      end
    end

    context "with boolean filters" do
      scenario "can_sponsor_visa filter is shown when true" do
        given_the_user_enables_visa_sponsorship_filter
        then_visa_sponsorship_filter_is_displayed
      end

      scenario "can_sponsor_visa filter is hidden when false" do
        given_the_user_visits_results_without_visa_sponsorship
        then_no_active_filters_are_displayed
      end

      scenario "send_courses filter is shown when true" do
        given_the_user_enables_send_courses_filter
        then_send_courses_filter_is_displayed
      end

      scenario "send_courses filter is hidden when false" do
        given_the_user_visits_results_without_send_courses
        then_no_active_filters_are_displayed
      end

      scenario "engineers_teach_physics filter is shown when true" do
        given_the_user_enables_engineers_teach_physics_filter
        then_the_active_filters_are_visible("Engineers teach physics")
      end

      scenario "engineers_teach_physics filter is hidden when false" do
        given_the_user_visits_results_without_engineers_teach_physics
        then_no_active_filters_are_displayed
      end
    end

    context "with dropdown/select filters" do
      scenario "level filter is shown when non-default value selected" do
        given_the_user_selects_level("further_education")
        then_further_education_level_filter_is_displayed
      end

      scenario "level filter is hidden when default value selected" do
        given_the_user_selects_level("all")
        then_no_active_filters_are_displayed
      end

      scenario "minimum_degree_required filter is shown when non-default value selected" do
        given_the_user_selects_minimum_degree("two_one")
        then_two_one_degree_filter_is_displayed
      end

      scenario "minimum_degree_required filter is hidden when default value selected" do
        given_the_user_selects_minimum_degree("show_all_courses")
        then_no_active_filters_are_displayed
      end

      scenario "interview_location filter is shown when set to online" do
        given_the_user_selects_interview_location("online")
        then_online_interview_location_filter_is_displayed
      end

      scenario "interview_location filter is hidden for other values" do
        given_the_user_selects_interview_location("in_person")
        then_no_active_filters_are_displayed
      end

      scenario "order filter is shown when non-default value selected" do
        given_the_user_selects_order("provider_name_ascending")
        then_provider_name_ascending_order_filter_is_displayed
      end
    end

    context "with complex filter combinations" do
      scenario "url with all filter types shows all corresponding active filters" do
        given_the_user_visits_results_with_complete_filter_url
        then_all_expected_filters_are_displayed
      end
    end
  end

  def given_the_user_visits_results_with_all_filters
    visit find_results_path(
      subjects: %w[00 G1 W1 C1],
      level: "further_education",
      send_courses: "true",
      funding: %w[fee salary],
      study_types: %w[full_time part_time],
      qualifications: %w[qts qts_with_pgce_or_pgde],
      minimum_degree_required: "two_one",
      can_sponsor_visa: "true",
      interview_location: "online",
    )
  end

  def given_the_user_visits_results_with_invalid_subjects
    visit find_results_path(subjects: %w[99 999])
  end

  def given_the_user_visits_results_with_invalid_funding
    visit find_results_path(funding: "invalid_funding")
  end

  def given_the_user_visits_results_with_invalid_study_types
    visit find_results_path(study_types: %w[invalid_study_type])
  end

  def given_the_user_visits_results_with_invalid_qualifications
    visit find_results_path(qualifications: %w[invalid_qualification])
  end

  def given_the_user_visits_results_with_invalid_level
    visit find_results_path(level: "invalid_level")
  end

  def given_the_user_visits_results_with_invalid_provider_code
    visit find_results_path(provider_code: "INVALID999")
  end

  def given_the_user_visits_results_with_mixed_valid_invalid_filters
    visit find_results_path(
      subjects: %w[00 99],
      funding: %w[fee invalid],
      level: "further_education",
    )
  end

  def given_the_user_searches_for_location(location)
    visit find_root_path
    fill_in "City, town or postcode", with: location
    and_clicks_search
  end

  def given_the_user_searches_for_location_with_radius(location, radius)
    visit find_results_path(location:, radius:)
  end

  def given_the_user_selects_multiple_subjects(*subjects)
    visit find_results_path(subjects: subjects_to_codes(*subjects))
  end

  def then_the_active_filters_are_visible(*filters)
    expect(active_filters).to include(*filters)
  end

  def given_the_user_selects_multiple_funding_types(*funding_types)
    visit find_results_path(funding: funding_types)
  end

  def given_the_user_selects_multiple_study_types(*study_types)
    visit find_results_path(study_types: study_types)
  end

  def given_the_user_selects_multiple_qualifications(*qualifications)
    visit find_results_path(qualifications: qualifications)
  end

  def given_the_user_enables_visa_sponsorship_filter
    visit find_results_path(can_sponsor_visa: "true")
  end

  def given_the_user_visits_results_without_visa_sponsorship
    visit find_results_path(can_sponsor_visa: "false")
  end

  def given_the_user_enables_send_courses_filter
    visit find_results_path(send_courses: "true")
  end

  def given_the_user_visits_results_without_send_courses
    visit find_results_path(send_courses: "false")
  end

  def given_the_user_enables_engineers_teach_physics_filter
    visit find_results_path(engineers_teach_physics: "true", subjects: %w[F3])
  end

  def given_the_user_visits_results_without_engineers_teach_physics
    visit find_results_path(engineers_teach_physics: "false")
  end

  def given_the_user_selects_level(level)
    visit find_results_path(level: level)
  end

  def given_the_user_selects_minimum_degree(degree)
    visit find_results_path(minimum_degree_required: degree)
  end

  def given_the_user_selects_interview_location(location)
    visit find_results_path(interview_location: location)
  end

  def given_the_user_selects_order(order)
    visit find_results_path(order: order)
  end

  def given_the_user_visits_results_with_complete_filter_url
    visit find_results_path(
      utm_source: "results",
      subject_name: "",
      subject_code: "",
      location: "London, UK",
      subjects: %w[00 01 W1 C1],
      level: "further_education",
      send_courses: "true",
      funding: %w[fee salary],
      study_types: %w[full_time part_time],
      qualifications: %w[qts qts_with_pgce_or_pgde],
      minimum_degree_required: "two_one",
      can_sponsor_visa: "true",
      interview_location: "online",
      provider_code: "",
      utm_medium: "apply_filters_bottom",
    )
  end

  def given_the_user_selects_multiple_filters
    given_the_user_visits_results_with_all_filters
  end

  def when_the_user_clicks_remove_on_fee_funding_filter
    find_filter_remove_button("Fee").click
  end

  def when_the_user_clicks_clear_all
    click_link "Clear all", match: :first
  end

  def when_the_user_changes_radius_to(radius, location:)
    visit find_results_path(location:, radius:)
  end

  def when_the_user_removes_location_filter
    find_filter_remove_button("London").click
  end

  def when_the_user_removes_subject_filter(subject)
    find_filter_remove_button(subject_name_to_label(subject)).click
  end

  def and_clicks_search
    click_button "Search"
  end

  def then_all_active_filters_are_displayed
    expect(page).to have_css(".app-c-filter-summary__heading", text: "Active filters")
    expect(page).to have_css(".app-c-filter-summary__remove-filter", minimum: 10)
  end

  def then_fee_funding_filter_is_removed
    expect(active_filters).not_to include("Fee-paying courses")
  end

  def and_other_filters_remain
    expect(active_filters).to include("Courses with a salary")
    expect(active_filters).to include("Further education")
  end

  def then_all_active_filters_are_cleared
    expect(page).not_to have_css(".app-c-filter-summary__remove-filter")
  end

  def and_user_sees_only_default_state
    expect(page).to have_current_path(find_results_path, ignore_query: true)
  end

  def then_no_active_filters_are_displayed
    expect(active_filters).to eq([])
  end

  def given_the_user_visits_results_with_invalid_filters
    visit find_results_path(
      order: "invalid_order",
      subjects: %w[ZZ ZZ2],
      subject_code: "ZZ",
      level: "invalid_level",
      send_courses: "not_a_boolean",
      funding: %w[invalid_funding another_invalid],
      study_types: %w[invalid_study_type another_invalid],
      qualifications: %w[invalid_qualification another_invalid],
      minimum_degree_required: "invalid_degree",
      can_sponsor_visa: "not_a_boolean",
      interview_location: "invalid_location",
      provider_code: "INVALID999",
      engineers_teach_physics: "not_a_boolean",
    )
  end

  def then_only_valid_filters_are_displayed
    expect(active_filters).to include("Primary") # 00 is valid
    expect(active_filters).to include("Fee-paying courses") # fee is valid
    expect(active_filters).to include("Further education") # level is valid
  end

  def then_location_filter_is_displayed(location)
    expect(active_filters).to include(location)
  end

  def and_radius_filter_is_displayed(radius)
    expect(active_filters).to include(radius)
  end

  def then_radius_filter_shows(radius)
    expect(active_filters).to include(radius)
  end

  def then_radius_filter_is_not_displayed
    expect(active_filters).not_to include("miles")
  end

  def then_primary_subject_filter_is_displayed
    expect(active_filters).to include("Primary")
  end

  def and_mathematics_subject_filter_is_displayed
    expect(active_filters).to include("Mathematics")
  end

  def and_each_can_be_removed_individually
    expect(all(".app-c-filter-summary__remove-filter").count).to be >= 2
  end

  def then_primary_filter_is_removed
    expect(active_filters).not_to include("Primary")
  end

  def and_mathematics_and_english_filters_remain
    expect(active_filters).to include("Mathematics")
    expect(active_filters).to include("English")
  end

  def then_fee_funding_filter_is_displayed
    expect(active_filters).to include("Fee-paying courses")
  end

  def and_salary_funding_filter_is_displayed
    expect(active_filters).to include("Courses with a salary")
  end

  def then_full_time_filter_is_displayed
    expect(active_filters).to include("Full-time")
  end

  def and_part_time_filter_is_displayed
    expect(active_filters).to include("Part-time")
  end

  def then_qts_filter_is_displayed
    expect(active_filters).to include("Qualification: QTS only")
  end

  def and_qts_with_pgce_or_pgde_filter_is_displayed
    expect(active_filters).to include("Qualification: QTS with PGCE or PGDE")
  end

  def then_visa_sponsorship_filter_is_displayed
    expect(active_filters).to include("Courses with visa sponsorship")
  end

  def then_send_courses_filter_is_displayed
    expect(active_filters).to include("Courses with a SEND specialism")
  end

  def then_further_education_level_filter_is_displayed
    expect(active_filters).to include("Further education")
  end

  def then_two_one_degree_filter_is_displayed
    expect(active_filters).to include("Degree grade: 2:1 or first")
  end

  def then_online_interview_location_filter_is_displayed
    expect(active_filters).to include("Courses with online interviews")
  end

  def then_provider_name_ascending_order_filter_is_displayed
    expect(active_filters).to include("Sort by: Provider (a to z)")
  end

  def active_filters
    page.all(".app-c-filter-summary li a").map { |element| element.text.split("\n") }
      .flatten
      .reject { |element| element.include?("Remove") }
  end

  def then_all_expected_filters_are_displayed
    expect(active_filters).to contain_exactly("Primary", "Primary with English", "Art and design", "Further education", "Fee-paying courses", "Courses with a salary", "Full-time", "Part-time", "Qualification: QTS only", "Qualification: QTS with PGCE or PGDE", "Degree grade: 2:1 or first", "Courses with visa sponsorship", "Courses with online interviews", "London", "Courses with a SEND specialism", "Biology")
  end

  def find_filter_remove_button(text)
    page.find(".app-c-filter-summary__remove-filter", text:)
  end

  def subjects_to_codes(*subjects)
    subject_mapping = {
      "Primary" => "00",
      "Secondary" => "01",
      "Mathematics" => "G1",
      "English" => "Q3",
    }
    subjects.map { |subject| subject_mapping[subject] }
  end

  def subject_name_to_label(subject)
    {
      "Primary" => "Primary",
      "Mathematics" => "Mathematics",
      "English" => "English",
    }[subject]
  end
end
