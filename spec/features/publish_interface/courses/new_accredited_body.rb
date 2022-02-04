require "rails_helper"

feature "selection accredited_bodies" do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_new_accredited_bodies_page
  end

  scenario "selecting multiple accredited_bodies" do
    when_i_select_an_accredited_body
    and_i_click_continue
    then_i_am_met_with_the_applications_open_page
  end

  scenario "invalid entries" do
    and_i_select_nothing
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_accredited_bodies_page
    new_accredited_body_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: accredited_body_params)
  end

  def when_i_select_an_accredited_body
    new_accredited_body_page.find("#course_accredited_body_code_a03").click
  end

  def and_i_select_nothing; end

  def and_i_click_continue
    new_accredited_body_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_applications_open_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/applications-open/new", ignore_query: true)
    expect(page).to have_content("When will applications open?")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Pick an accredited body")
  end
end
