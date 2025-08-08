require "rails_helper"

RSpec.describe "Publish - Missing provider information in course", service: :publish, type: :system do
  include DfESignInUserHelper
  include FeatureHelpers::GovukComponents

  # 1. Create a published course
  # 2. Set about us to blank
  # 3. Visit the preview
  # 4. Click the missing information link
  # 5. Fill out the missing information
  # 6. Assert redirect back to the about provider page
  scenario "filling out missing information returns you to the preview" do
    Timecop.travel Time.local(2025, 10, 1, 9, 0) do
      given_i_am_authenticated(user: user_with_course_in_2026_cycle)
      when_i_visit_the_publish_course_preview_page
      and_i_click_to_see_the_course_provider
      then_i_see_missing_information_link_for_provider_information

      when_i_click_the_missing_information_link
      and_i_fill_in_the_required_information
      and_submit_the_form
      then_i_am_redirected_back_to_the_provider_page
    end
  end

  def when_i_visit_the_publish_course_preview_page
    visit(preview_publish_provider_recruitment_cycle_course_path(
            provider_code: provider.provider_code,
            recruitment_cycle_year: provider.recruitment_cycle_year,
            code: course.course_code,
          ))
  end

  def and_i_click_to_see_the_course_provider
    within_summary_row "Provider" do
      page.click_link provider.provider_name
    end
  end

  def then_i_see_missing_information_link_for_provider_information
    expect(page).to have_link("Enter details about the training provider", href: edit_publish_provider_recruitment_cycle_why_train_with_us_path(@provider.provider_code, provider.recruitment_cycle_year, course_code: @course.course_code, goto_provider: true))
  end

  def when_i_click_the_missing_information_link
    page.click_link "Enter details about the training provider"
  end

  def and_i_fill_in_the_required_information
    fill_in "What kind of organisation is #{@provider.provider_name}?", with: "Some text"
    fill_in "Why should candidates choose to train with you?", with: "More text"
  end

  def and_submit_the_form
    click_button "Update why train with us"
  end

  def then_i_am_redirected_back_to_the_provider_page
    expect(page).to have_current_path(provider_publish_provider_recruitment_cycle_course_path(@provider.provider_code, provider.recruitment_cycle_year, code: @course.course_code))
  end

private

  attr_reader :course

  def provider
    @provider ||= @current_user.providers.first
  end

  def user_with_course_in_2026_cycle
    recruitment_cycle = find_or_create(:recruitment_cycle, :next, available_in_publish_from: 1.day.ago, available_for_support_users_from: 1.hour.ago)

    @course = build(
      :course,
      :publishable,
      applications_open_from: recruitment_cycle.application_end_date - 1.minute,
    )

    provider = create(
      :provider,
      about_us: nil,
      provider_value_proposition: nil,
      courses: [@course],
      recruitment_cycle:,
    )

    create(:user, providers: [provider])
  end
end
