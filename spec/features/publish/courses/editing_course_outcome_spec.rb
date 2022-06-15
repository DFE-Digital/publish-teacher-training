# frozen_string_literal: true

require "rails_helper"

feature "Editing course outcome", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "i can update the course outcome" do
    and_there_is_a_qts_course_i_want_to_edit
    when_i_visit_the_course_outcome_page
    and_i_update_the_course_outcome
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_outcome_is_updated
  end

  context "a course offering QTS" do
    scenario "shows the correct outcome options to choose from" do
      and_there_is_a_qts_course_i_want_to_edit
      when_i_visit_the_course_outcome_page
      then_i_am_shown_the_correct_qts_options
    end
  end

  context "a further education course not offering QTS" do
    scenario "shows the correct outcome options to choose from" do
      and_there_is_a_non_qts_course_i_want_to_edit
      when_i_visit_the_course_outcome_page
      then_i_am_shown_the_correct_non_qts_options
    end
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_qts_course_i_want_to_edit
    given_a_course_exists(:resulting_in_qts)
  end

  def and_there_is_a_non_qts_course_i_want_to_edit
    given_a_course_exists(:resulting_in_pgde, level: "further_education")
  end

  def when_i_visit_the_course_outcome_page
    outcome_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_update_the_course_outcome
    outcome_edit_page.pgce_with_qts.choose
  end

  def and_i_submit
    outcome_edit_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.value_saved", value: "course outcome"))
  end

  def and_the_course_outcome_is_updated
    expect(course.reload).to be_pgce_with_qts
  end

  def then_i_am_shown_the_correct_qts_options
    expect(outcome_edit_page.qualification_names).to match_array(
      ["QTS", "PGCE with QTS", "PGDE with QTS"],
    )
  end

  def then_i_am_shown_the_correct_non_qts_options
    expect(outcome_edit_page.qualification_names).to match_array(
      ["PGCE only (without QTS)", "PGDE only (without QTS)"],
    )
  end

  def provider
    @current_user.providers.first
  end
end
