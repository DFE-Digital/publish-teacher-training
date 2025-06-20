# frozen_string_literal: true

require "rails_helper"
require_relative "../filtering_helper"

RSpec.describe "when I filter by subject", :js, service: :find do
  include FilteringHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_courses_with_secondary_subjects
    and_there_are_courses_with_primary_subjects
    when_i_visit_the_find_results_page
  end

  scenario "filter by specific primary subjects" do
    when_i_filter_by_primary
    then_i_see_only_primary_specific_courses
    and_the_primary_option_is_checked
    and_i_see_that_there_is_one_course_found

    when_i_filter_by_primary_with_science_too
    then_i_see_primary_and_primary_with_science_courses
    and_the_primary_option_is_checked
    and_the_primary_with_science_option_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "filter by specific secondary subjects" do
    and_i_search_for_the_mathematics_option
    then_i_can_only_see_the_mathematics_option
    when_i_clear_my_search_for_secondary_options
    then_i_can_see_all_secondary_options
    when_i_filter_by_mathematics
    then_i_see_only_mathematics_courses
    and_the_mathematics_secondary_option_is_checked
    and_i_see_that_there_is_one_course_found

    when_i_search_for_specific_secondary_options
    then_i_can_only_see_options_that_i_searched

    when_i_clear_my_search_for_secondary_options
    then_i_can_see_all_secondary_options
  end

  scenario "filter by many secondary subjects" do
    and_i_filter_by_mathematics
    and_i_filter_by_chemistry
    then_i_see_mathematics_and_chemistry_courses
    and_the_mathematics_secondary_option_is_checked
    and_the_chemistry_secondary_option_is_checked
    and_i_see_that_two_courses_are_found
  end

  scenario "passing subjects on the parameters" do
    when_i_visit_the_find_results_page_passing_mathematics_in_the_params
    then_i_see_only_mathematics_courses
    and_the_mathematics_secondary_option_is_checked
    and_i_see_that_there_is_one_course_found
  end

  def when_i_visit_the_find_results_page_passing_mathematics_in_the_params
    visit(find_results_path(subjects: %w[G1]))
  end

  def and_i_search_for_the_mathematics_option
    page.find('[data-filter-search-target="searchInput"]').set("Math")
  end

  def then_i_can_only_see_the_mathematics_option
    expect(secondary_options).to eq(%w[Mathematics])
  end

  def then_i_can_see_all_secondary_options
    expect(secondary_options.size).to eq(37)
  end

  def when_i_search_for_specific_secondary_options
    page.find('[data-filter-search-target="searchInput"]').set("Com")
  end

  def then_i_can_only_see_options_that_i_searched
    expect(secondary_options).to eq(["Communication and media studies", "Computing"])
  end

  def when_i_clear_my_search_for_secondary_options
    fill_in "filter-search-0-input", with: ""
  end

  def when_i_filter_by_primary
    check "Primary", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_by_primary_with_science_too
    check "Primary with science", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_by_mathematics
    check "Mathematics", visible: :all
    and_i_apply_the_filters
  end
  alias_method :and_i_filter_by_mathematics, :when_i_filter_by_mathematics

  def and_i_filter_by_chemistry
    check "Chemistry", visible: :all
    and_i_apply_the_filters
  end

  def then_i_see_only_primary_specific_courses
    expect(results).to have_content("Primary (S872)")
    expect(results).to have_no_content("Primary with english")
    expect(results).to have_no_content("Primary with mathematics")
    expect(results).to have_no_content("Primary with science")
  end

  def then_i_see_primary_and_primary_with_science_courses
    expect(results).to have_content("Primary (S872)")
    expect(results).to have_content("Primary with science")
    expect(results).to have_no_content("Primary with english")
    expect(results).to have_no_content("Primary with mathematics")
  end

  def and_the_primary_option_is_checked
    expect(page).to have_checked_field("Primary", visible: :all)
  end

  def and_the_primary_with_science_option_is_checked
    expect(page).to have_checked_field("Primary with science", visible: :all)
  end

  def then_i_see_mathematics_and_chemistry_courses
    expect(results).to have_content("Mathematics")
    expect(results).to have_content("Chemistry")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Computing")
  end

  def and_the_mathematics_secondary_option_is_checked
    expect(page).to have_checked_field("Mathematics", visible: :all)
  end

  def and_the_chemistry_secondary_option_is_checked
    expect(page).to have_checked_field("Chemistry", visible: :all)
  end

  def secondary_options
    page.all('[data-filter-search-target="optionsList"]', wait: 2).flat_map { |subject| subject.text.split("\n") }
  end
end
