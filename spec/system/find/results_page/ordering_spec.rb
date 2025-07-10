# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search results ordering", :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)

    given_there_are_published_courses
  end

  scenario "sorting by course name" do
    when_i_visit_the_find_results_page
    then_the_courses_are_ordered_by_course_name_ascending

    when_i_click_on_the_second_page
    then_i_see_the_remaining_courses_ordered_by_course_name_ascending

    when_i_visit_the_find_results_page
    and_i_sort_courses_from_z_to_a
    then_the_courses_are_ordered_by_course_name_descending

    when_i_click_on_the_second_page
    then_i_see_the_remaining_courses_ordered_by_course_name_descending

    when_i_visit_the_find_results_page
    and_i_sort_courses_from_a_to_z
    then_the_courses_are_ordered_by_course_name_ascending

    when_i_click_on_the_second_page
    then_i_see_the_remaining_courses_ordered_by_course_name_ascending
  end

  scenario "sorting by provider name" do
    when_i_visit_the_find_results_page

    and_i_sort_providers_from_a_to_z
    then_the_courses_are_ordered_by_provider_name_ascending

    and_i_sort_providers_from_z_to_a
    then_the_courses_are_ordered_by_provider_name_descending
  end

  scenario "sorting by course name using the old parameter" do
    when_i_visit_the_find_results_page_using_the_old_course_name_descending
    then_the_courses_are_ordered_by_course_name_descending

    when_i_visit_the_find_results_page_using_the_old_course_name_ascending
    then_the_courses_are_ordered_by_course_name_ascending
  end

  scenario "sorting by provider name using the old parameter" do
    when_i_visit_the_find_results_page_using_the_old_provider_name_descending
    then_the_courses_are_ordered_by_provider_name_descending

    when_i_visit_the_find_results_page_using_the_old_provider_name_ascending
    then_the_courses_are_ordered_by_provider_name_ascending
  end

  def given_there_are_published_courses
    warwick_provider = create(:provider, provider_name: "Warwick University")
    niot_provider = create(:provider, provider_name: "NIoT")
    essex_provider = create(:provider, provider_name: "Essex University")
    cambridge_provider = create(:provider, provider_name: "Cambridge University")
    oxford_provider = create(:provider, provider_name: "Oxford University")

    create(:course, :with_full_time_sites, provider: warwick_provider, name: "Computing", course_code: "23TT")
    create(:course, :with_full_time_sites, provider: warwick_provider, name: "Art and Design", course_code: "X100")
    create(:course, :with_full_time_sites, provider: warwick_provider, name: "Drama", course_code: "AB21")
    create(:course, :with_full_time_sites, provider: warwick_provider, name: "Chemistry", course_code: "X121")

    create(:course, :with_full_time_sites, provider: niot_provider, name: "Economics", course_code: "23TX")
    create(:course, :with_full_time_sites, provider: niot_provider, name: "Psychology", course_code: "23X7")
    create(:course, :with_full_time_sites, provider: niot_provider, name: "History", course_code: "23X8")

    create(:course, :with_full_time_sites, provider: essex_provider, name: "Mathematics", course_code: "23X9")
    create(:course, :with_full_time_sites, provider: essex_provider, name: "Physics", course_code: "23XB")
    create(:course, :with_full_time_sites, provider: essex_provider, name: "Art and Design", course_code: "23XC")

    create(:course, :with_full_time_sites, provider: cambridge_provider, name: "Music", course_code: "23XD")
    create(:course, :with_full_time_sites, provider: cambridge_provider, name: "Dance", course_code: "23XF")

    create(:course, :with_full_time_sites, provider: oxford_provider, name: "Geography", course_code: "23XJ")
    create(:course, :with_full_time_sites, provider: oxford_provider, name: "English", course_code: "23XK")
    create(:course, :with_full_time_sites, provider: oxford_provider, name: "Philosophy", course_code: "T3XK")
  end

  def when_i_visit_the_find_results_page
    visit find_results_path
  end

  def when_i_visit_the_find_results_page_using_the_old_course_name_descending
    visit find_results_path(sortby: "course_desc")
  end

  def when_i_visit_the_find_results_page_using_the_old_course_name_ascending
    visit find_results_path(sortby: "course_asc")
  end

  def when_i_visit_the_find_results_page_using_the_old_provider_name_descending
    visit find_results_path(sortby: "provider_desc")
  end

  def when_i_visit_the_find_results_page_using_the_old_provider_name_ascending
    visit find_results_path(sortby: "provider_asc")
  end

  def when_i_click_on_the_second_page
    click_link_or_button "2"
  end

  def then_i_see_the_remaining_courses_ordered_by_course_name_ascending
    expect(result_titles).to eq(
      [
        "Essex University Mathematics (23X9)",
        "Cambridge University Music (23XD)",
        "Oxford University Philosophy (T3XK)",
        "Essex University Physics (23XB)",
        "NIoT Psychology (23X7)",
      ],
    )
  end

  def then_i_see_the_remaining_courses_ordered_by_course_name_descending
    expect(result_titles).to eq(
      [
        "Cambridge University Dance (23XF)",
        "Warwick University Computing (23TT)",
        "Warwick University Chemistry (X121)",
        "Essex University Art and Design (23XC)",
        "Warwick University Art and Design (X100)",
      ],
    )
  end

  def and_i_sort_courses_from_z_to_a
    select "Course name (Z-A)", from: "Sorted by"
    click_link_or_button "Sort"
  end

  def and_i_sort_courses_from_a_to_z
    select "Course name (A-Z)", from: "Sorted by"
    click_link_or_button "Sort"
  end

  def and_i_sort_providers_from_a_to_z
    select "Training provider (A-Z)", from: "Sorted by"
    click_link_or_button "Sort"
  end

  def and_i_sort_providers_from_z_to_a
    select "Training provider (Z-A)", from: "Sorted by"
    click_link_or_button "Sort"
  end

  def then_the_courses_are_ordered_by_course_name_ascending
    expect(result_titles).to eq(
      [
        "Essex University Art and Design (23XC)",
        "Warwick University Art and Design (X100)",
        "Warwick University Chemistry (X121)",
        "Warwick University Computing (23TT)",
        "Cambridge University Dance (23XF)",
        "Warwick University Drama (AB21)",
        "NIoT Economics (23TX)",
        "Oxford University English (23XK)",
        "Oxford University Geography (23XJ)",
        "NIoT History (23X8)",
      ],
    )
  end

  def then_the_courses_are_ordered_by_course_name_descending
    expect(result_titles).to eq(
      [
        "NIoT Psychology (23X7)",
        "Essex University Physics (23XB)",
        "Oxford University Philosophy (T3XK)",
        "Cambridge University Music (23XD)",
        "Essex University Mathematics (23X9)",
        "NIoT History (23X8)",
        "Oxford University Geography (23XJ)",
        "Oxford University English (23XK)",
        "NIoT Economics (23TX)",
        "Warwick University Drama (AB21)",
      ],
    )
  end

  def then_the_courses_are_ordered_by_provider_name_ascending
    expect(result_titles).to eq(
      [
        "Cambridge University Dance (23XF)",
        "Cambridge University Music (23XD)",
        "Essex University Art and Design (23XC)",
        "Essex University Mathematics (23X9)",
        "Essex University Physics (23XB)",
        "NIoT Economics (23TX)",
        "NIoT History (23X8)",
        "NIoT Psychology (23X7)",
        "Oxford University English (23XK)",
        "Oxford University Geography (23XJ)",
      ],
    )
  end

  def then_the_courses_are_ordered_by_provider_name_descending
    expect(result_titles).to eq(
      [
        "Warwick University Art and Design (X100)",
        "Warwick University Chemistry (X121)",
        "Warwick University Computing (23TT)",
        "Warwick University Drama (AB21)",
        "Oxford University English (23XK)",
        "Oxford University Geography (23XJ)",
        "Oxford University Philosophy (T3XK)",
        "NIoT Economics (23TX)",
        "NIoT History (23X8)",
        "NIoT Psychology (23X7)",
      ],
    )
  end

private

  def result_titles
    page.all(".govuk-summary-card__title", minimum: 5).map { |element| element.text.split("\n").join(" ") }
  end
end
