# frozen_string_literal: true

require "rails_helper"

feature "selection accredited_partners" do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_new_ratifying_providers_page
  end

  scenario "selecting multiple accredited_partners" do
    when_i_select_an_accredited_provider
    and_i_click_continue
    then_i_am_met_with_the_applications_open_page
  end

  scenario "invalid entries" do
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    provider = create(:provider)

    @accredited_provider = create(:course, :with_accrediting_provider, provider:).accrediting_provider
    create(:course, :with_accrediting_provider, provider:)

    @user = create(:user, providers: [provider])

    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_ratifying_providers_page
    publish_courses_new_ratifying_provider_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: accredited_provider_params)
  end

  def when_i_select_an_accredited_provider
    publish_courses_new_ratifying_provider_page.find("#course_accredited_provider_code_#{@accredited_provider.provider_code.downcase}").click
  end

  def and_i_click_continue
    publish_courses_new_ratifying_provider_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_applications_open_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/applications-open/new", ignore_query: true)
    expect(page).to have_content("Applications open date")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select an accredited provider")
  end
end
