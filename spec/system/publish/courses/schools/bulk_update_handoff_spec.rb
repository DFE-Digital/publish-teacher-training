# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish - Handing a placement school change on to the bulk update pages", type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_two_of_the_four_schools_are_attached_to_the_course
  end

  scenario "the button says what happens next" do
    when_i_visit_the_placement_schools_page

    expect(page).to have_button("Continue to choose which courses to apply this change to")
  end

  scenario "choosing schools asks which courses to apply them to" do
    when_i_visit_the_placement_schools_page
    and_i_check("Cedar School")
    and_i_submit

    then_i_am_asked_which_courses_to_apply_the_change_to
  end

  # Nothing is written until the provider has said which courses the change is
  # for, so cancelling out of the bulk pages leaves the course as it was.
  scenario "choosing schools writes nothing yet" do
    when_i_visit_the_placement_schools_page
    and_i_check("Cedar School")
    and_i_submit

    then_the_course_still_has_only(*attached_schools)
  end

  scenario "submitting no schools still asks for some" do
    when_i_visit_the_placement_schools_page
    and_i_uncheck(*attached_schools)
    and_i_submit

    then_i_see_an_error_asking_for_a_school
  end

  # Somebody who has just ticked their way through hundreds of schools cannot be
  # sent back to a form read afresh from the database.
  scenario "going back keeps the schools that were chosen" do
    when_i_visit_the_placement_schools_page
    and_i_check("Cedar School")
    and_i_submit
    and_i_go_back

    then_the_boxes_are_ticked_for(*attached_schools, "Cedar School")
  end

  scenario "submitting an unchanged selection updates nothing and says so" do
    when_i_visit_the_placement_schools_page
    and_i_submit

    then_i_am_on_the_basic_details_page
    and_i_see_the_schools_updated_message
  end

  # The section has no "your changes will go live" step: the provider is on
  # their way to the bulk update pages, which have a confirmation of their own.
  scenario "a published course goes straight on without an interstitial" do
    given_the_course_is_published
    when_i_visit_the_placement_schools_page
    and_i_check("Cedar School")
    and_i_submit

    then_i_am_asked_which_courses_to_apply_the_change_to
    and_i_do_not_see_the_live_changes_interstitial
  end

private

  attr_reader :provider, :course

  def attached_schools
    ["Ash Academy", "Beech School"]
  end

  def unattached_schools
    ["Cedar School", "Damson Primary School"]
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider)

    (attached_schools + unattached_schools).each do |location_name|
      create(:site, :with_provider_school, provider: @provider, location_name:)
    end

    given_i_am_authenticated(user: create(:user, providers: [@provider]))
    @provider.reload
  end

  def and_two_of_the_four_schools_are_attached_to_the_course
    @course = create(:course, provider:, sites: [])

    attached_schools.each do |location_name|
      provider_school = provider.schools.joins(:gias_school).find_by!(gias_school: { name: location_name })
      create(:course_school, course:, provider_school:, gias_school: provider_school.gias_school)
    end
  end

  def given_the_course_is_published
    course.enrichments << build(:course_enrichment, :published)
    course.save!
  end

  def when_i_visit_the_placement_schools_page
    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def and_i_check(school_name)
    check school_name
  end

  def and_i_uncheck(*school_names)
    school_names.each { |school_name| uncheck school_name }
  end

  def and_i_submit
    publish_course_school_edit_page.submit.click
  end

  def and_i_go_back
    click_link_or_button "Back"
  end

  def then_i_am_asked_which_courses_to_apply_the_change_to
    expect(page).to have_content("Updating placement schools")
    expect(page).to have_content("What courses do you want to apply this change to?")
  end

  def then_the_course_still_has_only(*school_names)
    expect(course.reload.schools.joins(:gias_school).pluck("gias_school.name")).to match_array(school_names)
  end

  def then_i_see_an_error_asking_for_a_school
    expect(page).to have_css(".govuk-error-summary")
  end

  def then_the_boxes_are_ticked_for(*school_names)
    school_names.each { |school_name| expect(page).to have_checked_field(school_name) }
    (unattached_schools - school_names).each { |school_name| expect(page).to have_unchecked_field(school_name) }
  end

  def then_i_am_on_the_basic_details_page
    expect(page).to have_current_path(
      details_publish_provider_recruitment_cycle_course_path(
        provider.provider_code,
        provider.recruitment_cycle_year,
        course.course_code,
      ),
    )
  end

  def and_i_see_the_schools_updated_message
    expect(page).to have_content("Schools updated")
  end

  def and_i_do_not_see_the_live_changes_interstitial
    expect(page).to have_no_content("Are you sure you want to publish")
  end
end
