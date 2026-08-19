# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Copying course information" do
  context "with accredited courses" do
    before do
      given_i_am_authenticated_as_an_accredited_provider_user
      and_there_is_a_course_i_want_to_edit

      when_i_visit_the_how_school_placements_work_page
      then_i_see_the_current_course_information
    end

    include_context "copy_courses"

    scenario "the course does not display its own name in the copy list" do
      when_i_visit_the_how_school_placements_work_page
      then_the_correct_courses_are_available_to_select

      when_i_select_a_course_to_copy
      and_i_click_copy
      then_i_see_an_alert_that_the_changes_are_not_saved_yet
      and_i_can_see_the_new_content
    end
  end

  context "with non accredited courses" do
    before do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_course_i_want_to_edit
      when_i_visit_the_how_school_placements_work_page
    end

    include_context "copy_courses"

    scenario "the course does not display its own name in the copy list" do
      when_i_visit_the_how_school_placements_work_page
      then_the_correct_courses_are_available_to_select
    end
  end

  context "when courses differ by funding and study mode" do
    before do
      given_i_am_authenticated_as_a_provider_user
      # The current course is excluded from the copy list.
      # The two copyable courses share qualification and start date,
      # so only funding and study mode should be displayed.
      given_a_course_exists(
        funding: :fee,
        qualification: "qts",
        study_mode: :full_time,
        start_date: Date.new(2026, 9, 1),
        enrichments: [build(:course_enrichment, :published)],
      )

      create(
        :course,
        provider: provider,
        name: "Biology",
        funding: :fee,
        study_mode: :full_time,
        qualification: "pgce_with_qts",
        start_date: Date.new(2026, 9, 1),
        enrichments: [build(:course_enrichment)],
      )

      create(
        :course,
        provider: provider,
        name: "Biology",
        funding: :salary,
        study_mode: :part_time,
        qualification: "pgce_with_qts",
        start_date: Date.new(2026, 9, 1),
        enrichments: [build(:course_enrichment)],
      )
    end

    scenario "shows only course information that differs between copyable courses" do
      when_i_visit_the_how_school_placements_work_page

      list_options = publish_course_information_edit_page.copy_content.copy_options

      dropdown_text = list_options.join(" ")

      expect(dropdown_text).to include("Fee-paying")
      expect(dropdown_text).to include("Salaried")

      expect(dropdown_text).to include("Full time")
      expect(dropdown_text).to include("Part time")

      expect(dropdown_text).not_to include("QTS with PGCE")
      expect(dropdown_text).not_to include("September 2026")
    end
  end

  context "when a course is selected to copy" do
    before do
      given_i_am_authenticated_as_a_provider_user

      given_a_course_exists(
        enrichments: [build(:course_enrichment, :published)],
      )

      create(
        :course,
        provider: provider,
        name: "Primary",
        course_code: "P123",
        age_range_in_years: "5_to_11",
        funding: :fee,
        study_mode: :full_time,
        qualification: "pgce_with_qts",
        start_date: Date.new(2026, 9, 1),
        enrichments: [build(:course_enrichment)],
      )
    end

    scenario "shows details for the selected primary course", :js do
      when_i_visit_the_how_school_placements_work_page
      select "Primary", from: "Copy from"

      expect(page).to have_css("[data-copy-course-content-target='details']")

      within "[data-copy-course-content-target='details']" do
        expect(page).to have_content("Primary (P123)")
        expect(page).to have_content("Ages 5 to 11")
        expect(page).to have_content("Fee-paying")
        expect(page).to have_content("QTS with PGCE")
        expect(page).to have_content("Full time")
        expect(page).to have_content("September 2026")
      end
    end
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def given_i_am_authenticated_as_an_accredited_provider_user
    given_i_am_authenticated(user: create(:user, :with_accredited_provider))
  end

  def and_there_is_an_accredited_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def and_there_is_an_accredited_course_i_want_to_edit
    given_a_course_exists(:with_accrediting_provider, enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_how_school_placements_work_page
    visit fields_school_placement_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      course.course_code,
    )
  end

  def then_i_see_the_current_course_information
    expect(page).to have_content(course.enrichments.first.how_school_placements_work)
  end

  def then_the_correct_courses_are_available_to_select
    list_options = publish_course_information_edit_page.copy_content.copy_options

    expect(Course.count).to eq 3
    expect(list_options.size).to eq 3
    expect(list_options.shift).to eq("Pick a course")
    expect(list_options.any? { |x| x[@course.name] }).to be_falsey

    # remaining options should always contain a course code
    expect(list_options).to all(match(/\([A-Z0-9]+\)/))

    # primary courses should show age range
    expect(list_options.join(" ")).to include("Ages")
  end

  def when_i_select_a_course_to_copy
    list_options = publish_course_information_edit_page.copy_content.copy_options
    @course_to_copy = list_options.second
    select @course_to_copy, from: "Copy from"
  end

  def and_i_click_copy
    click_link_or_button "Copy content"
  end

  def then_i_see_an_alert_that_the_changes_are_not_saved_yet
    copied_course_code = @course_to_copy.match(/\((.*?)\)/)[1]
    copied_course = Course.find_by(course_code: copied_course_code)

    expect(page).to have_content "Your changes are not yet saved"

    expect(page).to have_content(
      "We have copied these fields from #{copied_course.name} (#{copied_course.course_code})",
    )
  end

  def and_i_can_see_the_new_content
    copied_course_code = @course_to_copy.match(/\((.*?)\)/)[1]
    @copied_course = Course.find_by(course_code: copied_course_code)
    expect(page).to have_content(@copied_course.enrichments.first.placement_school_activities)
    expect(page).to have_content(@copied_course.enrichments.first.support_and_mentorship)
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
