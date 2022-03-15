require "rails_helper"

feature "selecting an age range" do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
  end

  scenario "selecting a preset age range" do
    when_i_visit_the_edit_age_range_page
    when_i_select_a_preset_age_range
    and_i_click_continue
    then_i_should_see_a_success_message
    and_the_course_age_range_is_updated("5_to_11")
  end

  scenario "selecting a custom age range" do
    when_i_visit_the_edit_age_range_page
    when_i_select_a_custom_age_range
    and_i_click_continue
    then_i_should_see_a_success_message
    and_the_course_age_range_is_updated("10_to_15")
  end

  scenario "selecting an invalid age range" do
    when_i_visit_the_edit_age_range_page
    when_i_select_an_invalid_age_range
    and_i_click_continue
    then_i_should_see_an_error_message
    and_the_course_age_range_is_not_updated
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_edit_age_range_page
    publish_course_age_range_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def when_i_select_a_preset_age_range
    publish_course_age_range_page.five_to_eleven.click
  end

  def when_i_select_a_custom_age_range
    publish_course_age_range_page.age_range_other.click
    publish_course_age_range_page.age_range_from_field.set("10")
    publish_course_age_range_page.age_range_to_field.set("15")
  end

  def when_i_select_an_invalid_age_range
    publish_course_age_range_page.age_range_other.click
    publish_course_age_range_page.age_range_from_field.set("10")
    publish_course_age_range_page.age_range_to_field.set("5")
  end

  def and_i_click_continue
    publish_course_age_range_page.continue.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.saved"))
  end

  def and_the_course_age_range_is_updated(age_range)
    @course = course.reload

    expect(@course.age_range_in_years).to eq(age_range)
  end

  def and_the_course_age_range_is_not_updated
    @course = course.reload

    expect(@course.age_range_in_years).to eq("3_to_7")
  end

  def then_i_should_see_an_error_message
    expect(publish_course_age_range_page.error_messages).to include(
      I18n.t("activemodel.errors.models.publish/age_range_form.attributes.course_age_range_in_years_other_from.invalid"),
    )
  end

  def provider
    @current_user.providers.first
  end
end
