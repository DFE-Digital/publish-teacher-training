# frozen_string_literal: true

require "rails_helper"

# These run on rack_test (no :js), proving the filters work without JavaScript:
# the "Apply filters" button submits a GET and the server renders the result.
RSpec.describe "Filtering the course list" do
  let(:provider) { create(:provider, :accredited_provider) }
  let(:cycle_year) { provider.recruitment_cycle_year.to_i }

  before do
    given_i_am_authenticated(user: create(:user, providers: [provider]))
  end

  scenario "I narrow the list to one status" do
    given_my_provider_has_courses_in_different_states
    when_i_visit_the_courses_page
    then_i_see_all_of_my_courses

    when_i_filter_by("Draft")
    then_i_see_only("Draft course")
    and_the_course_count_reads("1 course")
  end

  scenario "I choose several options within one group" do
    given_my_provider_has_courses_in_different_states
    when_i_visit_the_courses_page
    when_i_filter_by("Draft", "Withdrawn")
    then_i_see_only("Draft course", "Withdrawn course")
    and_the_course_count_reads("2 courses")
  end

  scenario "I combine filters from different groups" do
    given_my_provider_has_primary_and_secondary_courses
    when_i_visit_the_courses_page
    when_i_filter_by("Primary", "Fee-paying")
    then_i_see_only("Primary fee course")
  end

  scenario "I see which filters are active and can remove one" do
    given_my_provider_has_primary_and_secondary_courses
    when_i_visit_the_courses_page
    when_i_filter_by("Primary", "Fee-paying")
    then_i_see_active_filters("Primary", "Fee-paying")

    when_i_remove_the_active_filter("Primary")
    then_i_see_active_filters("Fee-paying")
    and_i_see_the_course("Secondary fee course")
  end

  scenario "I clear every filter at once" do
    given_my_provider_has_primary_and_secondary_courses
    when_i_visit_the_courses_page
    when_i_filter_by("Primary", "Fee-paying")
    when_i_clear_all_the_filters
    then_i_see_no_active_filters
    and_i_see_all_of_my_courses
  end

  scenario "I see how many options I have selected in each group" do
    given_my_provider_has_courses_in_different_states
    when_i_visit_the_courses_page
    when_i_filter_by("Draft", "Withdrawn")
    then_the_group_shows_the_selected_count("Status", "2 selected")
    and_the_other_groups_show_no_count
  end

  scenario "I filter everything out" do
    given_my_provider_has_primary_and_secondary_courses
    when_i_visit_the_courses_page
    when_i_filter_by("Further education")
    then_i_am_told_no_courses_were_found
  end

  scenario "I only see the start dates my courses use" do
    given_my_provider_has_courses_starting_in_different_months
    when_i_visit_the_courses_page
    then_the_start_date_group_offers("September #{cycle_year}", "January #{cycle_year + 1}")
  end

  scenario "I narrow the list to one start month" do
    given_my_provider_has_courses_starting_in_different_months
    when_i_visit_the_courses_page
    when_i_filter_by("September #{cycle_year}")
    then_i_see_only("September course")
    and_the_course_count_reads("1 course")
  end

  scenario "a bookmarked start month no course starts in is ignored" do
    given_my_provider_has_courses_starting_in_different_months
    when_i_visit_the_courses_page_with(start_date: ["#{cycle_year}-12"])
    then_i_see_only("September course", "January course")
    and_i_see_no_active_filters
  end

  scenario "an unrecognised filter in the address bar is ignored" do
    given_my_provider_has_primary_and_secondary_courses
    when_i_visit_the_courses_page_with(level: %w[bogus])
    then_i_see_all_of_my_courses
    and_i_see_no_active_filters
  end

  scenario "I only see the filters my courses actually vary on" do
    given_my_courses_vary_only_by_status_phase_and_funding
    when_i_visit_the_courses_page
    then_only_these_filters_are_shown("Status", "Education phase", "Fee or salary")
  end

  scenario "I see no filters at all when my courses are identical" do
    given_all_my_courses_are_identical
    when_i_visit_the_courses_page
    then_i_see_no_filter_sidebar
    and_i_still_see_my_courses
  end

  def given_my_provider_has_courses_in_different_states
    create(:course, :published_postgraduate, provider:, accrediting_provider: nil, name: "Open course")
    create(:course, :draft_enrichment, provider:, accrediting_provider: nil, name: "Draft course")
    create(:course, :withdrawn, provider:, accrediting_provider: nil, name: "Withdrawn course")
  end

  def given_my_provider_has_primary_and_secondary_courses
    create(:course, :primary, :fee, provider:, accrediting_provider: nil, name: "Primary fee course")
    create(:course, :secondary, :fee, provider:, accrediting_provider: nil, name: "Secondary fee course")
    create(:course, :primary, :salary, provider:, accrediting_provider: nil, name: "Primary salary course")
  end

  def given_my_provider_has_courses_starting_in_different_months
    create(:course, provider:, accrediting_provider: nil, name: "September course", start_date: Time.zone.local(cycle_year, 9, 1))
    create(:course, provider:, accrediting_provider: nil, name: "January course", start_date: Time.zone.local(cycle_year + 1, 1, 1))
  end

  def given_all_my_courses_are_identical
    start_date = Time.zone.local(provider.recruitment_cycle_year.to_i, 9, 1)
    create_list(:course, 3, :without_validation, :primary, :fee, provider:, accrediting_provider: nil,
                                                                 qualification: :qts, study_mode: :full_time, start_date:)
  end

  # Status, education phase and funding vary; qualification, study mode and start
  # date are identical across the two courses.
  def given_my_courses_vary_only_by_status_phase_and_funding
    start_date = Time.zone.local(provider.recruitment_cycle_year.to_i, 9, 1)
    create(:course, :published, :primary, :fee, provider:, accrediting_provider: nil, application_status: :open,
                                                qualification: :qts, study_mode: :full_time, start_date:, name: "Open primary fee course")
    create(:course, :draft_enrichment, :secondary, :salary, provider:, accrediting_provider: nil,
                                                            qualification: :qts, study_mode: :full_time, start_date:, name: "Draft secondary salary course")
  end

  def when_i_visit_the_courses_page(query = {})
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, **query,
    )
  end
  alias_method :when_i_visit_the_courses_page_with, :when_i_visit_the_courses_page

  def when_i_filter_by(*labels)
    labels.each { |label| when_i_check(label) }
    publish_provider_courses_index_page.apply_filters.click
  end

  # A collapsed group hides its checkboxes, so expand it first, as a provider would.
  def when_i_check(label)
    group = group_offering(label)
    group.find("summary").click unless group[:open]
    check(label)
  end

  def group_offering(label)
    publish_provider_courses_index_page.filter_groups.find { |group| group.option_labels.include?(label) }&.root_element
  end

  def when_i_remove_the_active_filter(label)
    publish_provider_courses_index_page.active_filters.chips.find { |chip| chip.text.include?(label) }.click
  end

  def when_i_clear_all_the_filters
    publish_provider_courses_index_page.active_filters.clear_all.click
  end

  def then_i_see_only(*names)
    expect(course_names).to match_array(names)
  end

  def then_i_see_all_of_my_courses
    expect(course_names.size).to eq(3)
  end
  alias_method :and_i_see_all_of_my_courses, :then_i_see_all_of_my_courses

  def and_i_see_the_course(name)
    expect(course_names).to include(name)
  end

  def and_the_course_count_reads(text)
    expect(publish_provider_courses_index_page.course_counts.map(&:text)).to eq([text])
  end

  # Each chip carries a visually hidden "Remove filter" for screen readers.
  def then_i_see_active_filters(*labels)
    chips = publish_provider_courses_index_page.active_filters.chips.map { |chip| chip.text.sub("Remove filter", "").strip }

    expect(chips).to eq(labels)
  end

  def then_i_see_no_active_filters
    expect(publish_provider_courses_index_page).to have_no_active_filters
  end
  alias_method :and_i_see_no_active_filters, :then_i_see_no_active_filters

  def then_only_these_filters_are_shown(*headings)
    expect(publish_provider_courses_index_page.filter_group_headings).to eq(headings)
  end

  def then_i_see_no_filter_sidebar
    expect(publish_provider_courses_index_page).to have_no_filter_heading
    expect(publish_provider_courses_index_page).to have_no_filter_groups
  end

  def and_i_still_see_my_courses
    expect(course_names.size).to eq(3)
  end

  def then_the_group_shows_the_selected_count(heading, text)
    group = filter_group(heading)

    expect(group.selected_count.text).to eq(text)
  end

  def and_the_other_groups_show_no_count
    others = publish_provider_courses_index_page.filter_groups.reject { |group| group.heading.text == "Status" }

    expect(others.map(&:has_selected_count?)).to all(be(false))
  end

  def then_i_am_told_no_courses_were_found
    expect(publish_provider_courses_index_page.empty_message.text).to eq("No courses found")
  end

  def then_the_start_date_group_offers(*labels)
    expect(filter_group("Start date").option_labels).to eq(labels)
  end

  # Course links read "Primary fee course (X123)"; the code is noise here.
  def course_names
    publish_provider_courses_index_page.courses.flat_map do |section|
      section.all(".app-table--courses__course-name a").map { |link| link.text.sub(/\s+\(\w+\)\z/, "") }
    end
  end

  def filter_group(heading)
    publish_provider_courses_index_page.filter_groups.find { |group| group.heading.text == heading }
  end
end
