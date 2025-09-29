# frozen_string_literal: true

require "rails_helper"

feature "selecting Design and technology specialisms" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "selecting D&T specialisms routes to age range" do
    when_i_visit_the_new_course_design_technology_page
    when_i_select_a_design_technology_specialism
    and_i_click_continue
    then_i_am_met_with_the_age_range_page
  end

  scenario "D&T master with Modern languages subordinate routes to Modern languages" do
    when_i_visit_the_new_course_design_technology_page_with_subordinate(:modern_languages)
    when_i_select_a_design_technology_specialism
    and_i_click_continue
    then_i_am_met_with_the_modern_languages_page
  end

  scenario "Physics master with D&T subordinate routes to D&T specialisms" do
    when_i_visit_the_new_engineers_teach_physics_page_with_subordinate(:design_and_technology)
    when_i_choose_engineers_teach_physics_yes
    and_i_click_continue
    then_i_am_met_with_the_design_technology_page
  end

  scenario "Selecting more than two specialisms reverts name to just Design and technology" do
    given_a_design_and_technology_course_exists
    when_i_visit_the_edit_course_design_technology_page
    when_i_select_three_design_technology_specialisms
    and_i_save_changes
    then_the_course_name_shows_just_design_and_technology
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def design_technology_subject
    @design_technology_subject ||= find(:secondary_subject, :design_and_technology)
  end

  def new_course_design_technology_query_params
    Rack::Utils.build_nested_query(
      course: {
        is_send: 0,
        level: "secondary",
        master_subject_id: design_technology_subject.id,
        subjects_ids: [design_technology_subject.id],
      },
    )
  end

  def new_course_design_technology_with_subordinate_query_params(subordinate_key)
    subordinate = course_subject(subordinate_key)
    Rack::Utils.build_nested_query(
      course: {
        is_send: 0,
        level: "secondary",
        master_subject_id: design_technology_subject.id,
        subordinate_subject_id: subordinate.id,
        subjects_ids: [design_technology_subject.id, subordinate.id],
      },
    )
  end

  def when_i_visit_the_new_course_design_technology_page
    visit "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/design-technology/new?#{new_course_design_technology_query_params}"
  end

  def when_i_visit_the_new_course_design_technology_page_with_subordinate(subordinate_key)
    visit "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/design-technology/new?#{new_course_design_technology_with_subordinate_query_params(subordinate_key)}"
  end

  def when_i_visit_the_new_engineers_teach_physics_page_with_subordinate(subordinate_key)
    subordinate = course_subject(subordinate_key)
    physics = course_subject(:physics)
    query = Rack::Utils.build_nested_query(
      course: {
        is_send: 0,
        level: "secondary",
        master_subject_id: physics.id,
        subordinate_subject_id: subordinate.id,
        subjects_ids: [physics.id, subordinate.id],
      },
    )
    visit "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/engineers-teach-physics/new?#{query}"
  end

  def when_i_select_a_design_technology_specialism
    within(".govuk-checkboxes") do
      check("Engineering")
    end
  end

  def when_i_select_three_design_technology_specialisms
    within(".govuk-checkboxes") do
      check("Engineering")
      check("Product design")
      check("Food technology")
    end
  end

  def and_i_click_continue
    click_button "Continue"
  end

  def then_i_am_met_with_the_age_range_page
    expect(page).to have_current_path(
      "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/age-range/new",
      ignore_query: true,
    )
    expect(page).to have_content("Age range")
  end

  def then_i_am_met_with_the_modern_languages_page
    expect(page).to have_current_path(
      "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/modern-languages/new",
      ignore_query: true,
    )
    expect(page).to have_content("Languages")
  end

  def then_i_am_met_with_the_engineers_teach_physics_page
    expect(page).to have_current_path(
      "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/engineers-teach-physics/new",
      ignore_query: true,
    )
    expect(page).to have_content("Engineers Teach Physics")
  end

  def then_i_am_met_with_the_design_technology_page
    expect(page).to have_current_path(
      "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/design-technology/new",
      ignore_query: true,
    )
    expect(page).to have_content("Specialisms")
  end

  def and_i_save_changes
    click_button "Save"
  end

  def when_i_choose_engineers_teach_physics_yes
    within(".govuk-radios") do
      choose("Yes")
    end
  end

  def then_the_course_name_shows_just_design_and_technology
    expect(page).to have_current_path(
      "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{@course.course_code}/details",
      ignore_query: true,
    )
    within(".govuk-heading-l, h1") do
      expect(page).to have_text("Design and technology")
      expect(page).not_to have_text("Engineering")
      expect(page).not_to have_text("Product design")
      expect(page).not_to have_text("Food technology")
    end
  end

  def given_a_design_and_technology_course_exists
    @course = create(
      :course,
      :secondary,
      provider: provider,
      subjects: [find_or_create(:secondary_subject, :design_and_technology)],
    )
  end

  def when_i_visit_the_edit_course_design_technology_page
    visit "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{@course.course_code}/design-technology?#{edit_course_design_technology_query_params}"
  end

  def edit_course_design_technology_query_params
    Rack::Utils.build_nested_query(
      course: {
        subjects_ids: [design_technology_subject.id],
      },
    )
  end

  def course_subject(subject_key)
    case subject_key
    when :physics
      find_or_create(:secondary_subject, :physics)
    when :modern_languages
      find_or_create(:secondary_subject, :modern_languages)
    when :design_and_technology
      find_or_create(:secondary_subject, :design_and_technology)
    else
      raise "Unknown subject key: #{subject_key}"
    end
  end
end
