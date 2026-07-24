# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing course schools after the school remodel", travel: mid_cycle(2027) do
  attr_reader :course

  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_provider_school
    and_there_is_a_course_i_want_to_edit
    and_the_course_school_update_fails_after_validation
    when_i_visit_the_publish_course_school_edit_page
  end

  scenario "i see an error when the selected school cannot be resolved while saving" do
    then_i_should_see_a_list_of_schools
    when_i_select_the_school
    and_i_submit
    then_i_should_see_the_school_selection_error
    and_the_error_is_reported_to_sentry
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [provider]),
    )
  end

  def and_there_is_a_provider_school
    @provider_school = create(
      :provider_school,
      provider:,
      gias_school: create(:gias_school, name: "School 1"),
    )
  end

  def and_there_is_a_course_i_want_to_edit
    @course = create(:course, provider:)
  end

  def and_the_course_school_update_fails_after_validation
    allow(Publish::Schools::UpdateCourseSchoolsService).to receive(:call_or_enqueue).and_raise(unresolved_provider_school_error)
    allow(Sentry).to receive(:capture_exception)
  end

  def when_i_visit_the_publish_course_school_edit_page
    visit schools_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      course.course_code,
    )
  end

  def then_i_should_see_a_list_of_schools
    expect(page).to have_content("School 1")
  end

  def when_i_select_the_school
    check "School 1"
  end

  def and_i_submit
    click_link_or_button "Update placement school"
  end

  def then_i_should_see_the_school_selection_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.publish/course_school_form.attributes.school_uuids.school_uuids_invalid"),
    )
  end

  def and_the_error_is_reported_to_sentry
    expect(Sentry).to have_received(:capture_exception).with(unresolved_provider_school_error)
  end

  def provider
    @provider ||= create(:provider, recruitment_cycle:)
  end

  def recruitment_cycle
    @recruitment_cycle ||= find_or_create(:recruitment_cycle, year: 2027)
  end

  def unresolved_provider_school_error
    @unresolved_provider_school_error ||=
      Publish::Schools::UpdateCourseProviderSchoolsService::UnresolvedProviderSchoolsError.new("no provider_school")
  end
end
