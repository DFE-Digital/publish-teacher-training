require "rails_helper"

feature "V2 Publishing a course with validation errors", type: :feature do
  before do
    FeatureFlag.activate(:long_form_content)
    given_i_am_authenticated_as_a_provider_user
    and_there_is_an_invalid_course_i_want_to_publish
    provider.update_columns(train_with_disability: nil, about_us: nil, value_proposition: nil)

    when_i_visit_the_course_page
    click_button "Publish course"
    expect(page).to have_css(".govuk-error-summary")
  end

  scenario "Placement selection criteria can't be blank error link navigates to the placement selection criteria field" do
    click_link_in_error_summary("Placement selection criteria can't be blank")
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{@course.course_code}/fields/where-you-will-train", ignore_query: true)
    expect(page).to have_content("Where you will train")
  end

  scenario "Duration per school can't be blank error link navigates to the duration per school field" do
    click_link_in_error_summary("Duration per school can't be blank")
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{@course.course_code}/fields/where-you-will-train", ignore_query: true)
    expect(page).to have_content("Where you will train")
  end

  scenario "Placement school activities can't be blank error link navigates to the placement school activities field" do
    click_link_in_error_summary("Placement school activities can't be blank")
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{@course.course_code}/fields/school-placement", ignore_query: true)
    expect(page).to have_content("What you will do on school placements")
  end

  scenario "Enter details about theoretical training activities error link navigates to the theoretical training activities field" do
    click_link_in_error_summary("Enter details about theoretical training activities")
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{@course.course_code}/fields/what-you-will-study", ignore_query: true)
    expect(page).to have_content("What you will study")
  end

  scenario "Provider train with disability Reduce the word count for provider train with disability error link navigates to the disability support field" do
    click_link_in_error_summary("Enter details about training with a disability")
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/training-with-disabilities/edit", ignore_query: true)
    expect(page).to have_content("Training with disabilities")
  end

  scenario "Tell candidates about your organisation error link navigates to the about your organisation field" do
    click_link_in_error_summary("Tell candidates about your organisation")
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/why-train-with-us/edit", ignore_query: true)
    expect(page).to have_content("Why train with us")
  end

  scenario "Enter why candidates should choose to train with you error link navigates to the value proposition field" do
    click_link_in_error_summary("Enter why candidates should choose to train with you")
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/why-train-with-us/edit", ignore_query: true)
    expect(page).to have_content("Why train with us")
  end

private

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def click_link_in_error_summary(link_text)
    within ".govuk-error-summary" do
      page.find_link(link_text).click
    end
  end

  def and_there_is_an_invalid_course_i_want_to_publish
    given_a_course_exists(
      :with_accrediting_provider,
      :salary,
      degree_grade: nil,
      accrediting_provider:,
    )
  end

  def accrediting_provider
    build(:accredited_provider)
  end

  def provider
    @user.providers.first
  end
end
