require "rails_helper"

feature "selecting a course outcome", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_new_outcome_page
  end

  scenario "selecting qts" do
    when_i_select_an_outcome(:qts)
    and_i_click_continue
    then_i_am_met_with_the_funding_type_page(:qts)
  end

  scenario "selecting pgce with qts" do
    when_i_select_an_outcome(:pgce_with_qts)
    and_i_click_continue
    then_i_am_met_with_the_funding_type_page(:pgce_with_qts)
  end

  scenario "selecting pgde with qts" do
    when_i_select_an_outcome(:pgde_with_qts)
    and_i_click_continue
    then_i_am_met_with_the_funding_type_page(:pgde_with_qts)
  end

  scenario "invalid entries" do
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_outcome_page
    new_outcome_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: outcome_params)
  end

  def when_i_select_an_outcome(outcome)
    new_outcome_page.qualification_fields.send(outcome).click
  end

  def and_i_click_continue
    new_outcome_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_funding_type_page(outcome)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/funding-type/new#{selected_params(outcome)}")
    expect(page).to have_content("Funding type")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Pick an outcome")
  end

  def selected_params(outcome)
    "?course%5Bage_range_in_years%5D=%5B%223_to_7%22%5D&course%5Bis_send%5D=%5B%220%22%5D&course%5Blevel%5D=primary&course%5Bqualification%5D=#{outcome}&course%5Bsubjects_ids%5D%5B%5D=2"
  end
end
