require "rails_helper"

feature "course confirmation", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_course_confirmation_page
  end

  scenario "creating course" do
    and_i_click_continue

    then_i_am_met_with_the_provider_courses_index_page
  end

  scenario "it displays the correct information" do
    then_it_displays_correctly
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, providers: [build(:provider, sites: [build(:site)])])
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_course_confirmation_page
    course_confirmation_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      query: confirmation_params(provider),
    )
  end

  def and_i_click_continue
    course_confirmation_page.save_button.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def site
    @site ||= provider.sites.first
  end

  def then_i_am_met_with_the_provider_courses_index_page
    expect(provider_courses_index_page).to be_displayed
    expect(provider_courses_index_page.success_summary).to have_content("Your course has been created")
  end

  def then_it_displays_correctly
    expect(page.title).to start_with("Check your answers before confirming")

    expect(course_confirmation_page.title).to have_content("Check your answers before confirming")
    expect(course_confirmation_page.details.level.value.text).to eq("Secondary")
    expect(course_confirmation_page.details.is_send.value.text).to eq("No")
    expect(course_confirmation_page.details.subjects.value.text).to include("Psychology")
    expect(course_confirmation_page.details.age_range.value.text).to eq("14 to 19")
    expect(course_confirmation_page.details.study_mode.value.text).to eq("Full time or part time")
    expect(course_confirmation_page.details.locations.value.text).to have_content(site.location_name)
    expect(course_confirmation_page.details.applications_open.value.text).to eq("12 October 2021")
    expect(course_confirmation_page.details.start_date.value.text).to eq("October 2021")
    expect(course_confirmation_page.details.name.value.text).to eq("Psychology")
    expect(course_confirmation_page.details.description.value.text).to eq("PGDE with QTS, full time or part time teaching apprenticeship")
    expect(course_confirmation_page.preview.name.text).to include("#{provider.provider_name} Psychology")
    expect(course_confirmation_page.preview.description.text).to include("Course: PGDE with QTS, full time or part time teaching apprenticeship")
  end
end
