require "rails_helper"

RSpec.describe "Publish - Missing provider information in course", service: :publish, type: :system do
  include DfESignInUserHelper
  include FeatureHelpers::GovukComponents

  # 1. Create a draft course
  # 2. Set about us to blank
  # 3. Visit the preview
  # 4. Click the missing information link
  # 5. Fill out the missing information
  # 6. Assert redirect back to the about provider page
  scenario "filling out missing information returns you to the preview" do
    Timecop.travel Find::CycleTimetable.mid_cycle do
      given_i_am_authenticated(user: user_with_course)
      when_i_visit_the_publish_course_preview_page
      and_i_click_to_see_the_disability_information
      then_i_see_missing_information_link_for_provider_information

      when_i_click_the_missing_information_link
      and_i_fill_in_the_required_information
      and_submit_the_form
      then_i_am_redirected_back_to_the_disability_support_page
    end
  end

  def when_i_visit_the_publish_course_preview_page
    visit(preview_publish_provider_recruitment_cycle_course_path(
            provider_code: provider.provider_code,
            recruitment_cycle_year: provider.recruitment_cycle_year,
            code: course.course_code,
          ))
  end

  def and_i_click_to_see_the_disability_information
    page.click_link "Find out about training with disabilities and other needs"
  end

  def then_i_see_missing_information_link_for_provider_information
    expect(page).to have_link("Enter details about training with disabilities and other needs", href: edit_publish_provider_recruitment_cycle_disability_support_path(@provider.provider_code, provider.recruitment_cycle_year, course_code: @course.course_code, goto_training_with_disabilities: true))
  end

  def when_i_click_the_missing_information_link
    page.click_link "Enter details about training with disabilities and other needs"
  end

  def and_i_fill_in_the_required_information
    page.find("#publish-disability-support-form-train-with-disability-field").set("Some text")
  end

  def and_submit_the_form
    click_button "Update training with disabilities"
  end

  def then_i_am_redirected_back_to_the_disability_support_page
    expect(page).to have_current_path(training_with_disabilities_publish_provider_recruitment_cycle_course_path(@provider.provider_code, provider.recruitment_cycle_year, code: @course.course_code))
  end

private

  attr_reader :course

  def provider
    @provider ||= @current_user.providers.first
  end

  def user_with_course
    recruitment_cycle = find_or_create(:recruitment_cycle)

    @course = build(
      :course,
      :publishable,
    )

    provider = create(
      :provider,
      train_with_disability: nil,
      value_proposition: nil,
      courses: [@course],
      recruitment_cycle:,
    )

    create(:user, providers: [provider])
  end
end
