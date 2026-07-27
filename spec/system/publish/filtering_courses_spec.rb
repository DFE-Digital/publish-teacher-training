# frozen_string_literal: true

require "rails_helper"

# Not tagged :js, so these run on rack_test and prove the filters work with
# JavaScript disabled. The one :js scenario at the end covers the enhancement.
RSpec.describe "Filtering the course list" do
  let(:provider) { create(:provider, :accredited_provider) }

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

  scenario "I can filter by any month the cycle allows" do
    given_my_provider_has_courses_starting_in_different_months
    when_i_visit_the_courses_page
    then_i_can_choose_a_start_month
  end

  scenario "an unrecognised filter in the address bar is ignored" do
    given_my_provider_has_primary_and_secondary_courses
    when_i_visit_the_courses_page_with(level: %w[bogus])
    then_i_see_all_of_my_courses
    and_i_see_no_active_filters
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
    create(:course, provider:, accrediting_provider: nil, name: "September course", start_date: Time.zone.local(provider.recruitment_cycle_year.to_i, 9, 1))
    create(:course, provider:, accrediting_provider: nil, name: "January course", start_date: Time.zone.local(provider.recruitment_cycle_year.to_i + 1, 1, 1))
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

  # A collapsed group's labels read as empty text, so ask for the hidden text too.
  def group_offering(label)
    publish_provider_courses_index_page.filter_groups.map(&:root_element).find do |group|
      group.all("label", visible: :all).any? { |option| option.text(:all).strip == label }
    end
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

  def then_i_can_choose_a_start_month
    month = "September #{provider.recruitment_cycle_year}"
    group_offering(month).find("summary").click

    expect(page).to have_field(month, type: "checkbox")
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
