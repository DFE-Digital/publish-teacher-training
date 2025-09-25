# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search results tracking", :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)

    double = instance_double(Find::Analytics::SearchResultsEvent)
    allow(Find::Analytics::SearchResultsEvent).to receive(:new).and_return(double)
    allow(double).to receive(:send_event)

    given_some_courses_exist

    when_i_visit_the_homepage
  end

  scenario "when searching from the homepage form" do
    when_i_click_search
    then_one_search_result_is_tracked_from_homepage_form
    and_i_am_on_the_results_page
  end

  scenario "when browse primary courses" do
    when_i_browse_primary_courses
    and_i_choose_primary
    and_i_click_find_primary_courses
    then_one_search_result_is_tracked_from_primary_courses_form
    and_i_am_on_the_results_page
  end

  scenario "when browse secondary courses" do
    when_i_browse_secondary_courses
    and_i_choose_art_and_design
    and_i_click_find_secondary_courses
    then_one_search_result_is_tracked_from_secondary_courses_form
    and_i_am_on_the_results_page
  end

  scenario "when browse apprenticeship courses" do
    when_i_browse_all_apprenticeship_courses
    then_one_search_result_is_tracked_from_browse_all_apprenticeship_courses_link
    and_i_am_on_the_results_page
    then_i_see_only_apprenticeship_courses
  end

  scenario "when browse SEND primary courses" do
    when_i_browse_send_primary_courses
    then_one_search_result_is_tracked_from_send_primary_link
    and_i_am_on_the_results_page
  end

  scenario "when browse SEND secondary courses" do
    when_i_browse_send_secondary_courses
    then_one_search_result_is_tracked_from_send_secondary_link
    and_i_am_on_the_results_page
  end

  scenario "when browse further education courses" do
    when_i_browse_further_education_courses
    then_one_search_result_is_tracked_from_further_education_link
    and_i_am_on_the_results_page
  end

  def given_some_courses_exist
    create(
      :course,
      :with_full_time_sites,
      :secondary,
      :open,
      name: "Biology",
      course_code: "2DTK",
      provider: build(:provider, provider_name: "London university", provider_code: "19S"),
    )
    create(
      :course,
      :with_full_time_sites,
      :published_teacher_degree_apprenticeship,
      :secondary,
      :open,
      name: "Mathematics",
      course_code: "TDA1",
      provider: build(:provider, provider_name: "Bristol university", provider_code: "23T"),
      degree_grade: "not_required",
    )
    create(
      :course,
      :with_full_time_sites,
      :open,
      name: "PGTA History",
      course_code: "PGTA1",
      provider: build(:provider, provider_name: "Exeter university", provider_code: "EX1"),
      funding: "apprenticeship",
    )
    create(
      :course,
      :with_full_time_sites,
      :primary,
      :open,
      :with_special_education_needs,
      name: "Primary (SEND)",
      course_code: "P123",
      provider: build(:provider, provider_name: "Bath university", provider_code: "PO1"),
    )
    create(
      :course,
      :with_full_time_sites,
      :secondary,
      :open,
      :with_special_education_needs,
      name: "Art and design (SEND)",
      course_code: "F314",
      provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
    create(
      :course,
      :with_full_time_sites,
      :open,
      name: "Further Education",
      course_code: "F3D",
      provider: build(:provider, provider_name: "Birmingham university", provider_code: "JL1"),
      level: "further_education",
    )
    create(
      :course,
      :with_full_time_sites,
      :primary,
      :open,
      name: "Primary",
      course_code: "Y565",
      provider: build(:provider, provider_name: "Brighton university", provider_code: "1UR"),
    )

    subject_group = create(:subject_group, name: "Arts, humanities and social sciences")
    find_or_create(:secondary_subject, :art_and_design).update(subject_group:)
  end

  def when_i_visit_the_homepage
    visit root_path
  end

  def when_i_click_search
    click_link_or_button "Search"
  end

  def then_one_search_result_is_tracked_from_homepage_form
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 7,
          page: 1,
          search_params: hash_including(applications_open: true),
          track_params: hash_including(utm_source: "home", utm_medium: "main_search"),
          results: array_including(
            have_attributes(course_code: "F314", provider_code: "RO1"),
            have_attributes(course_code: "2DTK", provider_code: "19S"),
            have_attributes(course_code: "F3D", provider_code: "JL1"),
            have_attributes(course_code: "TDA1", provider_code: "23T"),
            have_attributes(course_code: "PGTA1", provider_code: "EX1"),
            have_attributes(course_code: "Y565", provider_code: "1UR"),
            have_attributes(course_code: "P123", provider_code: "PO1"),
          ),
        ),
      )
    end
  end

  def and_i_am_on_the_results_page
    expect(page).to have_current_path(find_results_path, ignore_query: true)
  end

  def when_i_browse_primary_courses
    click_link_or_button "Browse primary courses"
  end

  def and_i_choose_primary
    check "Primary", visible: :all
  end

  def and_i_click_find_primary_courses
    click_link_or_button "Find primary courses"
  end

  def then_one_search_result_is_tracked_from_primary_courses_form
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 2,
          page: 1,
          search_params: hash_including(applications_open: true, subjects: %w[00]),
          track_params: hash_including(utm_source: "home", utm_medium: "primary_courses"),
          results: array_including(
            have_attributes(course_code: "Y565", provider_code: "1UR"),
            have_attributes(course_code: "P123", provider_code: "PO1"),
          ),
        ),
      )
    end
  end

  def when_i_browse_secondary_courses
    click_link_or_button "Browse secondary courses"
  end

  def and_i_choose_art_and_design
    check "Art and design", visible: :all
  end

  def and_i_click_find_secondary_courses
    click_link_or_button "Find secondary courses"
  end

  def then_one_search_result_is_tracked_from_secondary_courses_form
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, subjects: %w[W1]),
          track_params: hash_including(utm_source: "home", utm_medium: "secondary_courses"),
          results: array_including(
            have_attributes(course_code: "F314", provider_code: "RO1"),
          ),
        ),
      )
    end
  end

  def and_all_accordions_are_open
    page.all(".govuk-accordion__section-button").map(&:click)
  end

  def when_i_browse_all_apprenticeship_courses
    and_all_accordions_are_open
    click_link_or_button "Browse all apprenticeship courses."
  end

  def then_one_search_result_is_tracked_from_browse_all_apprenticeship_courses_link
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, minimum_degree_required: "show_all_courses", funding: "apprenticeship"),
          track_params: hash_including(utm_source: "home", utm_medium: "all_apprenticeship_courses"),
          results: array_including(
            have_attributes(course_code: "TDA1", provider_code: "23T"),
          ),
        ),
      )
    end
  end

  def then_i_see_only_apprenticeship_courses
    within(".app-filter-layout__content") do
      expect(page).to have_content("Mathematics")
      expect(page).to have_content("PGTA History")
      expect(page).not_to have_content("Biology")
      expect(page).not_to have_content("Further Education")
    end
  end

  def when_i_browse_send_primary_courses
    and_all_accordions_are_open
    click_link_or_button "Browse primary courses with a SEND specialism."
  end

  def when_i_browse_send_secondary_courses
    and_all_accordions_are_open
    click_link_or_button "Browse secondary courses with a SEND specialism."
  end

  def then_one_search_result_is_tracked_from_send_primary_link
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, send_courses: true, subjects: Subject.primary_subject_codes),
          track_params: hash_including(utm_source: "home", utm_medium: "send_primary_courses"),
          results: array_including(
            have_attributes(course_code: "P123", provider_code: "PO1"),
          ),
        ),
      )
    end
  end

  def then_one_search_result_is_tracked_from_send_secondary_link
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, send_courses: true, subjects: Subject.secondary_subject_codes_with_incentives),
          track_params: hash_including(utm_source: "home", utm_medium: "send_secondary_courses"),
          results: array_including(
            have_attributes(course_code: "F314", provider_code: "RO1"),
          ),
        ),
      )
    end
  end

  def when_i_browse_further_education_courses
    and_all_accordions_are_open
    click_link_or_button "Browse further education courses."
  end

  def then_one_search_result_is_tracked_from_further_education_link
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, level: "further_education"),
          track_params: hash_including(utm_source: "home", utm_medium: "further_education_courses"),
          results: array_including(
            have_attributes(course_code: "F3D", provider_code: "JL1"),
          ),
        ),
      )
    end
  end
end
