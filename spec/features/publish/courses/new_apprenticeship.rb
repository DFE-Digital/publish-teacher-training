require "rails_helper"

feature "selecting a teaching apprenticeship" do
  before do
    given_i_am_authenticated_as_an_ab_provider_user
    when_i_visit_the_apprenticeship_page
  end

  scenario "selecting yes" do
    when_i_select(:yes)
    and_i_click_continue
    then_i_am_met_with_the_full_or_part_time_page
  end

  scenario "selecting no" do
    when_i_select(:no)
    and_i_click_continue
    then_i_am_met_with_the_full_or_part_time_page
  end

  scenario "invalid entries" do
    and_i_select_nothing
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_an_ab_provider_user
    @user = create(:user)
    @user.providers << create(:provider, :accredited_body)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_apprenticeship_page
    new_apprenticeship_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: outcome_params)
  end

  def when_i_select(choice)
    new_apprenticeship_page.send(choice).click
  end

  def and_i_select_nothing; end

  def and_i_click_continue
    new_apprenticeship_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_full_or_part_time_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/full-part-time/new", ignore_query: true)
    expect(page).to have_content("Full time or part time?")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a program type")
  end
end
