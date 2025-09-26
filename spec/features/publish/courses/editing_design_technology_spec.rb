# frozen_string_literal: true

require "rails_helper"

feature "Editing Design and technology specialisms" do
  scenario "selecting a specialism saves and returns to details" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_secondary_course_i_want_to_edit

    when_i_visit_the_edit_course_design_technology_page
    when_i_select_a_specialism
    and_i_click_continue
    then_i_am_met_with_course_details_page
    and_i_should_see_a_success_message
  end

  scenario "redirect due to lacking design technology id in query" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_secondary_course_i_want_to_edit

    when_i_visit_the_edit_course_design_technology_page(with_invalid_query: true)
    then_i_am_redirected_to_course_details_page
  end

  scenario "selecting two specialisms with a subordinate subject updates course name" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_secondary_course_i_want_to_edit

    when_i_visit_the_edit_course_design_technology_page_with_subordinate(:psychology)
    when_i_select_two_specialisms("Electronics", "Food technology")
    and_i_click_continue
    then_i_see_the_course_name_with_two_specialisms_and_subordinate
  end

private

  def and_there_is_a_secondary_course_i_want_to_edit
    given_a_course_exists(:secondary)
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.saved", value: "Design and technology"))
    expect(page).to have_content(specialism_name)
  end

  def design_technology_subject
    @design_technology ||= find(:secondary_subject, :design_and_technology)
  end

  def specialism_name
    @specialism_name ||= "Engineering"
  end

  def when_i_select_a_specialism
    within(".govuk-checkboxes") { check specialism_name }
  end

  def edit_course_design_technology_page_with_query(invalid: false)
    params = {}
    params = {}.merge('course[subjects_ids][]': design_technology_subject.id) unless invalid
    params
  end

  def when_i_visit_the_edit_course_design_technology_page(with_invalid_query: false)
    query = edit_course_design_technology_page_with_query(invalid: with_invalid_query)
    visit "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/design-technology?#{query.to_query}"
  end

  def when_i_visit_the_edit_course_design_technology_page_with_subordinate(subordinate_key)
    subordinate = case subordinate_key
                  when :psychology then find_or_create(:secondary_subject, :psychology)
                  else raise "Unknown subordinate subject: #{subordinate_key}"
                  end

    query = Rack::Utils.build_nested_query(
      course: {
        subjects_ids: [design_technology_subject.id, subordinate.id],
      },
    )

    visit "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/design-technology?#{query}"
  end

  def and_i_click_continue
    click_button "Save"
  end

  def provider
    @provider ||= @current_user.providers.first
  end

  def course
    @course ||= provider.courses.first
  end

  def then_i_am_met_with_course_details_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/details")
  end

  def when_i_select_two_specialisms(first_label, second_label)
    within(".govuk-checkboxes") do
      check first_label
      check second_label
    end
  end

  def then_i_see_the_course_name_with_two_specialisms_and_subordinate
    expect(page).to have_content("Design and technology (Electronics and Food technology) with psychology")
    expect(page).to have_content("(#{course.course_code})")
  end

  def then_i_am_redirected_to_course_details_page
    then_i_am_met_with_course_details_page
  end
end
