require "rails_helper"

feature "choosing a start date" do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_new_start_date_page
  end

  scenario "selecting september" do
    when_i_select_september
    and_i_click_continue
    then_i_am_met_with_the_confirmation_page
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_start_date_page
    new_start_date_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: start_date_params(provider))
  end

  def when_i_select_september; end

  def and_i_click_continue
    new_start_date_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_confirmation_page
    expect(page.current_path).to match("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/confirmation/confirmation")
    expect(page).to have_content("Check your answers before confirming")
  end
end
