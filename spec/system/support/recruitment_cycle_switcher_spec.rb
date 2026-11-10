# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support recruitment cycle switcher" do
  scenario "the switcher is hidden outside rollover", travel: mid_cycle(2025) do
    given_there_is_a_provider
    and_i_am_authenticated_as_an_admin_user

    when_the_current_providers_list_hides_the_switcher
    when_a_provider_hides_the_switcher
    when_onboarding_hides_the_switcher
  end

  scenario "the switcher follows the provider and onboarding pages during rollover", travel: 1.hour.before(find_closes(2025)) do
    given_there_is_a_next_recruitment_cycle
    and_there_is_a_provider_in_each_cycle
    and_there_is_a_candidate
    and_i_am_authenticated_as_an_admin_user

    when_the_current_cycle_provider_pages_show_the_current_cycle
    when_the_next_cycle_provider_pages_show_the_next_cycle
    when_onboarding_shows_the_current_cycle
    when_changing_the_cycle_opens_the_list
    when_other_support_pages_hide_the_switcher
  end

private

  def current_year
    Find::CycleTimetable.current_year
  end

  def given_there_is_a_next_recruitment_cycle
    find_or_create(:recruitment_cycle, :next)
  end

  def given_there_is_a_provider
    provider
  end

  def and_there_is_a_provider_in_each_cycle
    provider
    next_provider
  end

  def and_there_is_a_candidate
    candidate
  end

  def provider
    @provider ||= create(:provider)
  end

  def next_provider
    @next_provider ||= create(:provider, :next_recruitment_cycle)
  end

  def candidate
    @candidate ||= create(:candidate)
  end

  def and_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def when_the_current_providers_list_hides_the_switcher
    visit_page support_recruitment_cycle_providers_path(current_year), "Providers"
    expect_no_cycle_switcher
  end

  def when_a_provider_hides_the_switcher
    visit_page support_recruitment_cycle_provider_path(current_year, provider), provider.name_and_code
    expect_no_cycle_switcher
  end

  def when_onboarding_hides_the_switcher
    visit_page support_providers_onboarding_form_requests_path, "Onboard a provider"
    expect_no_cycle_switcher
  end

  def when_the_current_cycle_provider_pages_show_the_current_cycle
    when_the_current_providers_list_shows_the_current_cycle
    when_a_provider_shows_the_current_cycle
    when_a_providers_courses_show_the_current_cycle
  end

  def when_the_next_cycle_provider_pages_show_the_next_cycle
    when_the_next_providers_list_shows_the_next_cycle
    when_a_next_cycle_provider_shows_the_next_cycle
  end

  def when_other_support_pages_hide_the_switcher
    when_users_hide_the_switcher
    when_a_users_providers_hide_the_switcher
    when_data_exports_hide_the_switcher
    when_candidates_hide_the_switcher
    when_a_candidates_details_hide_the_switcher
    when_feedback_hides_the_switcher
    when_subjects_hide_the_switcher
    when_financial_incentives_hide_the_switcher
    when_settings_hide_the_switcher
    when_feature_flags_hide_the_switcher
    when_recruitment_cycles_hide_the_switcher
    when_banners_hide_the_switcher
  end

  def when_the_current_providers_list_shows_the_current_cycle
    visit_page support_recruitment_cycle_providers_path(current_year), "Providers"
    expect_current_cycle_switcher
  end

  def when_a_provider_shows_the_current_cycle
    visit_page support_recruitment_cycle_provider_path(current_year, provider), provider.name_and_code
    expect_current_cycle_switcher
  end

  def when_a_providers_courses_show_the_current_cycle
    visit_page support_recruitment_cycle_provider_courses_path(current_year, provider), provider.name_and_code
    expect_current_cycle_switcher
  end

  def when_the_next_providers_list_shows_the_next_cycle
    visit_page support_recruitment_cycle_providers_path(current_year + 1), "Providers"
    expect_next_cycle_switcher
  end

  def when_a_next_cycle_provider_shows_the_next_cycle
    visit_page support_recruitment_cycle_provider_path(current_year + 1, next_provider), next_provider.name_and_code
    expect_next_cycle_switcher
  end

  def when_onboarding_shows_the_current_cycle
    visit_page support_providers_onboarding_form_requests_path, "Onboard a provider"
    expect_current_cycle_switcher
  end

  def when_changing_the_cycle_opens_the_list
    visit_page support_recruitment_cycle_providers_path(current_year), "Providers"
    click_link "Change recruitment cycle"

    expect(page).to have_css("h1", text: "Recruitment Cycles")
    expect(page).to have_link(
      "#{current_year - 1} to #{current_year} - current",
      href: support_recruitment_cycle_providers_path(current_year),
    )
    expect(page).to have_link(
      "#{current_year} to #{current_year + 1}",
      href: support_recruitment_cycle_providers_path(current_year + 1),
    )
    expect_no_cycle_switcher
  end

  def when_users_hide_the_switcher
    visit_page support_recruitment_cycle_users_path(current_year), "Users"
    expect_no_cycle_switcher
  end

  def when_a_users_providers_hide_the_switcher
    visit_page support_recruitment_cycle_user_providers_path(current_year, current_user), current_user.full_name
    expect_no_cycle_switcher
  end

  def when_data_exports_hide_the_switcher
    visit_page support_recruitment_cycle_data_exports_path(current_year), "Download Publish users"
    expect_no_cycle_switcher
  end

  def when_candidates_hide_the_switcher
    visit_page support_candidates_path, "Candidates"
    expect_no_cycle_switcher
  end

  def when_a_candidates_details_hide_the_switcher
    visit_page details_support_candidate_path(candidate), candidate.email_address
    expect_no_cycle_switcher
  end

  def when_feedback_hides_the_switcher
    visit_page support_feedback_index_path, "Feedback on Find teacher training courses"
    expect_no_cycle_switcher
  end

  def when_subjects_hide_the_switcher
    visit_page support_subjects_path, "Subjects"
    expect_no_cycle_switcher
  end

  def when_financial_incentives_hide_the_switcher
    visit_page support_financial_incentives_path, "Financial incentives"
    expect_no_cycle_switcher
  end

  def when_settings_hide_the_switcher
    visit_page support_settings_path, "Settings"
    expect_no_cycle_switcher
  end

  def when_feature_flags_hide_the_switcher
    visit_page support_feature_flags_path, "Feature flags"
    expect_no_cycle_switcher
  end

  def when_recruitment_cycles_hide_the_switcher
    visit_page support_recruitment_cycles_path, "Recruitment Cycles"
    expect_no_cycle_switcher
  end

  def when_banners_hide_the_switcher
    visit_page active_support_banners_path, "Banners"
    expect_no_cycle_switcher
  end

  def visit_page(path, heading)
    visit path
    expect(page).to have_css("h1", text: heading)
  end

  def expect_current_cycle_switcher
    within(".title-bar") do
      expect(page).to have_text("Recruitment cycle #{current_year - 1} to #{current_year} - current")
      expect(page).to have_link("Change recruitment cycle", href: support_root_path)
    end
  end

  def expect_next_cycle_switcher
    within(".title-bar") do
      expect(page).to have_text("Recruitment cycle #{current_year} to #{current_year + 1}")
      expect(page).to have_no_text("- current")
      expect(page).to have_link("Change recruitment cycle", href: support_root_path)
    end
  end

  def expect_no_cycle_switcher
    expect(page).to have_no_css(".title-bar")
    expect(page).to have_no_link("Change recruitment cycle")
  end
end
