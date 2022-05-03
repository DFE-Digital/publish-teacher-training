# frozen_string_literal: true

require "rails_helper"

feature "Editing course study mode" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "i can update the course study mode" do
    and_there_is_a_part_time_course_i_want_to_edit
    when_i_visit_the_course_study_mode_page
    and_i_choose_a_full_time_study_mode
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_study_mode_is_updated
  end

  scenario "updating with invalid data" do
    and_there_is_a_course_with_no_study_mode
    when_i_visit_the_course_study_mode_page
    and_i_submit
    then_i_should_see_an_error_message
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_part_time_course_i_want_to_edit
    given_a_course_exists(study_mode: :part_time)
  end

  def and_there_is_a_course_with_no_study_mode
    given_a_course_exists
    @course.update_column(:study_mode, nil)
  end

  def when_i_visit_the_course_study_mode_page
    publish_course_study_mode_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_choose_a_full_time_study_mode
    publish_course_study_mode_page.full_time.choose
  end

  def and_i_submit
    publish_course_study_mode_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.value_saved", value: "full or part time"))
  end

  def and_the_course_study_mode_is_updated
    expect(course.reload).to be_full_time
  end

  def then_i_should_see_an_error_message
    expect(publish_course_study_mode_page.error_messages).to include(
      I18n.t("activemodel.errors.models.publish/course_study_mode_form.attributes.study_mode.blank"),
    )
  end

  def provider
    @current_user.providers.first
  end
end
