# frozen_string_literal: true

require "rails_helper"

feature "choosing a start date" do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_publish_courses_new_start_date_page
  end

  scenario "selecting january" do
    when_i_select_january
    and_i_click_continue
    then_i_am_met_with_the_confirmation_page
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_publish_courses_new_start_date_page
    publish_courses_new_start_date_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Find::CycleTimetable.current_year, query: start_date_params(provider))
  end

  def when_i_select_january
    publish_courses_new_start_date_page.choose("January #{Find::CycleTimetable.next_year}")
  end

  def and_i_click_continue
    publish_courses_new_start_date_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_confirmation_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Find::CycleTimetable.current_year}/courses/confirmation", ignore_query: true)
    expect(page).to have_content("Check your answers")
  end
end
