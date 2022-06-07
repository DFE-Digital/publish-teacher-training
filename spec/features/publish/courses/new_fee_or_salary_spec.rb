require "rails_helper"

feature "selecting a fee or salary", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_new_fee_or_salary_page
  end

  scenario "selecting fee paying" do
    when_i_select_an_fee_or_salary(:fee)
    and_i_click_continue
    then_i_am_met_with_the_full_or_part_time_page(:fee)
  end

  scenario "selecting salaried" do
    when_i_select_an_fee_or_salary(:salary)
    and_i_click_continue
    then_i_am_met_with_the_full_or_part_time_page(:salary)
  end

  scenario "selecting apprenticeship" do
    when_i_select_an_fee_or_salary(:apprenticeship)
    and_i_click_continue
    then_i_am_met_with_the_full_or_part_time_page(:apprenticeship)
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

  def when_i_visit_the_new_fee_or_salary_page
    new_fee_or_salary_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: fee_or_salary_params)
  end

  def when_i_select_an_fee_or_salary(funding_type)
    new_fee_or_salary_page.funding_type_fields.send(funding_type).click
  end

  def and_i_click_continue
    new_fee_or_salary_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_full_or_part_time_page(fee_or_salary)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/full-part-time/new#{selected_params(fee_or_salary)}")
    expect(page).to have_content("Full time or part time?")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a program type")
  end

  def selected_params(funding_type)
    "?course%5Bage_range_in_years%5D=%5B%223_to_7%22%5D&course%5Bfunding_type%5D=#{funding_type}&course%5Bis_send%5D=%5B%220%22%5D&course%5Blevel%5D=primary&course%5Bsubjects_ids%5D%5B%5D=2"
  end
end
