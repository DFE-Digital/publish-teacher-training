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
    and_i_sort_courses_from_a_to_z
    then_the_courses_are_ordered_by_course_name_ascending

    when_i_click_on_the_second_page
    then_i_see_the_remaining_courses_ordered_by_course_name_ascending
  end

  scenario "sorting by provider name" do
    when_i_visit_the_find_results_page

    and_i_sort_providers_from_a_to_z
    then_the_courses_are_ordered_by_provider_name_ascending
  end

  scenario "sorting by start date" do
    when_i_visit_the_find_results_page

    and_i_sort_start_date
    then_the_courses_are_ordered_by_start_date
  end

  def given_there_are_published_courses
    warwick_provider = create(:provider, provider_name: "Warwick University")
    niot_provider = create(:provider, provider_name: "NIoT")
    essex_provider = create(:provider, provider_name: "Essex University")
    cambridge_provider = create(:provider, provider_name: "Cambridge University")
    oxford_provider = create(:provider, provider_name: "Oxford University")

    with_options start_date: 5.days.from_now, provider: warwick_provider do
      create(:course, :with_full_time_sites, name: "Computing", course_code: "23TT")
      create(:course, :with_full_time_sites, name: "Art and Design", course_code: "X100")
      create(:course, :with_full_time_sites, name: "Drama", course_code: "AB21")
      create(:course, :with_full_time_sites, name: "Chemistry", course_code: "X121")
    end

    with_options start_date: 1.day.from_now, provider: niot_provider do
      create(:course, :with_full_time_sites, name: "Economics", course_code: "23TX")
      create(:course, :with_full_time_sites, name: "Psychology", course_code: "23X7")
      create(:course, :with_full_time_sites, name: "History", course_code: "23X8")
    end

    with_options start_date: 2.days.from_now, provider: essex_provider do
      create(:course, :with_full_time_sites, name: "Mathematics", course_code: "23X9")
      create(:course, :with_full_time_sites, name: "Physics", course_code: "23XB")
      create(:course, :with_full_time_sites, name: "Art and Design", course_code: "23XC")
    end

    with_options start_date: 4.days.from_now, provider: cambridge_provider do
      create(:course, :with_full_time_sites, name: "Music", course_code: "23XD")
      create(:course, :with_full_time_sites, name: "Dance", course_code: "23XF")
    end

    with_options start_date: 3.days.from_now, provider: oxford_provider do
      create(:course, :with_full_time_sites, name: "Geography", course_code: "23XJ")
      create(:course, :with_full_time_sites, name: "English", course_code: "23XK")
      create(:course, :with_full_time_sites, name: "Philosophy", course_code: "T3XK")
    end
  end

  def when_i_visit_the_find_results_page
    visit find_results_path
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

  def and_i_sort_courses_from_a_to_z
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Course name (a to z)", visible: :hidden
    click_link_or_button "Apply filters"
  end

  def and_i_sort_providers_from_a_to_z
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Training provider (a to z)", visible: :hidden
    click_link_or_button "Apply filters"
  end

  def and_i_sort_start_date
    page.find("h3", text: "Sort by", normalize_ws: true).click
    choose "Soonest start date", visible: :hidden
    click_link_or_button "Apply filters"
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

  def then_the_courses_are_ordered_by_start_date
    expect(result_titles).to eq(
      [
        "NIoT Economics (23TX)",
        "NIoT History (23X8)",
        "NIoT Psychology (23X7)",
        "Essex University Art and Design (23XC)",
        "Essex University Mathematics (23X9)",
        "Essex University Physics (23XB)",
        "Oxford University English (23XK)",
        "Oxford University Geography (23XJ)",
        "Oxford University Philosophy (T3XK)",
        "Cambridge University Dance (23XF)",
      ],
    )
  end

private

  def result_titles
    page.all(".govuk-summary-card__title", minimum: 5).map { |element| element.text.split("\n").join(" ") }
  end
end
