# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Course preview", service: :publish, travel: mid_cycle do
  include Rails.application.routes.url_helpers

  scenario "Apply button sits above the course summary" do
    given_i_am_authenticated(user: user_with_a_course)
    when_i_visit_the_publish_course_preview_page
    then_the_apply_button_appears_above_the_course_summary
  end

  context "when candidate accounts is active" do
    before do
      FeatureFlag.activate(:candidate_accounts)
    end

    scenario "the save prompt is shown next to the apply button but is not interactive" do
      given_i_am_authenticated(user: user_with_a_course)
      when_i_visit_the_publish_course_preview_page
      then_i_see_the_sign_in_to_save_prompt
      and_the_save_prompt_is_not_interactive
    end
  end

  context "when candidate accounts is not active" do
    scenario "no save prompt is shown" do
      given_i_am_authenticated(user: user_with_a_course)
      when_i_visit_the_publish_course_preview_page
      then_i_do_not_see_the_sign_in_to_save_prompt
    end
  end

private

  def user_with_a_course
    @provider = create(:provider, recruitment_cycle:)

    @course = create(:course, :secondary, :with_accrediting_provider, :open, provider:)

    @provider.accredited_partnerships.create(accredited_provider: @course.accrediting_provider)

    create(:user, providers: [@provider])
  end

  def when_i_visit_the_publish_course_preview_page
    visit preview_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      code: course.course_code,
    )
  end

  def then_the_apply_button_appears_above_the_course_summary
    expect(page).to have_link("Apply for this course")
    expect(page).to have_css("h2", text: "Course summary")

    expect(page.text.index("Apply for this course")).to be < page.text.index("Course summary")
  end

  def then_i_see_the_sign_in_to_save_prompt
    expect(page).to have_css(".save-course-button__text", text: "Sign in to save this course")
  end

  def and_the_save_prompt_is_not_interactive
    expect(page).to have_no_link("Sign in to save this course")
    expect(page).to have_no_button("Sign in to save this course")
    expect(page).to have_no_content("Save this course for later")
  end

  def then_i_do_not_see_the_sign_in_to_save_prompt
    expect(page).to have_no_content("Sign in to save this course")
  end

  def provider
    @provider ||= @current_user.providers.first
  end

  def recruitment_cycle
    @recruitment_cycle ||= Current.recruitment_cycle
  end

  def course
    @course ||= provider.courses.first
  end
end
