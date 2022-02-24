# frozen_string_literal: true

require "rails_helper"

feature "Editing course locations" do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_course_locations_page
  end

  scenario "i can update the course locations" do
    then_i_should_see_a_list_of_locations
    when_i_update_the_course_locations
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_locations_are_updated
  end

  scenario "updating with invalid data" do
    and_i_submit
    then_i_should_see_an_error_message
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          build(
            :provider,
            sites: [
              build(:site, location_name: "Site 1"),
              build(:site, location_name: "Site 2"),
            ],
          ),
        ],
      ),
    )
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(sites: [])
  end

  def when_i_visit_the_course_locations_page
    publish_course_location_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def then_i_should_see_a_list_of_locations
    expect(publish_course_location_page.vacancy_names).to match_array(["Site 1", "Site 2"])
  end

  def when_i_update_the_course_locations
    publish_course_location_page.vacancies.find do |el|
      el.find(".govuk-label").text == "Site 1"
    end.check
  end

  def and_i_submit
    publish_course_location_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content("Course locations saved")
  end

  def and_the_course_locations_are_updated
    expect(course.reload.sites.map(&:location_name)).to match_array(["Site 1"])
  end

  def then_i_should_see_an_error_message
    expect(publish_course_location_page).to have_content(
      I18n.t("activemodel.errors.models.publish/course_location_form.attributes.site_ids.no_locations"),
    )
  end

  def provider
    @current_user.providers.first
  end
end
