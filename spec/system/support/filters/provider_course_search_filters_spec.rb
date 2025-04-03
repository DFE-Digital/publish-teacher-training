# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filter providers by type" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_are_providers_with_different_types
    when_i_visit_the_providers_index_page
    i_see_all_the_providers
  end

  context "filter by" do
    scenario "scitt provider" do
      when_i_filter_scitt_providers
      and_when_i_click_apply_filters
      i_see_only_the_scitt_providers
    end

    scenario "university provider" do
      when_i_filter_university_providers
      and_when_i_click_apply_filters
      i_see_only_the_university_providers
    end

    scenario "lead school provider" do
      when_i_filter_lead_school_providers
      and_when_i_click_apply_filters
      i_see_only_the_lead_school_providers
    end
  end

  context "removing filters" do
    scenario "removing selected filters" do
      when_i_filter_university_providers
      and_when_i_click_apply_filters

      i_can_remove_filters
      and_i_can_see_unfiltered_results
    end
  end

private

  def i_see_all_the_providers
    expect(page).to have_content(@provider_hei.provider_name)
  end

  def when_i_filter_scitt_providers
    support_provider_index_page.scitt_provider_filter.click
  end

  def when_i_filter_university_providers
    support_provider_index_page.university_provider_filter.click
  end

  def when_i_filter_lead_school_providers
    support_provider_index_page.lead_school_provider_filter.click
  end

  def i_see_only_the_scitt_providers
    expect(page).to have_content(@provider_scitt.provider_name)
    expect(page).to have_no_content(@provider_hei.provider_name)
    expect(page).to have_no_content(@provider_lead_school.provider_name)
  end

  def i_see_only_the_university_providers
    expect(page).to have_content(@provider_hei.provider_name)
    expect(page).to have_no_content(@provider_scitt.provider_name)
    expect(page).to have_no_content(@provider_lead_school.provider_name)
  end

  def i_see_only_the_lead_school_providers
    expect(page).to have_content(@provider_lead_school.provider_name)
    expect(page).to have_no_content(@provider_scitt.provider_name)
    expect(page).to have_no_content(@provider_hei.provider_name)
  end

  def and_there_are_providers_with_different_types
    @provider_scitt = create(:provider, :scitt)
    @provider_hei = create(:provider, :university)
    @provider_lead_school = create(:provider, :lead_school)
  end

  def when_i_visit_the_providers_index_page
    support_provider_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def and_when_i_click_apply_filters
    support_provider_index_page.apply_filters.click
  end

  def i_can_remove_filters
    support_provider_index_page.remove_filters.click
  end

  def and_i_can_see_unfiltered_results
    expect(support_provider_index_page).to have_content(@provider_lead_school.provider_name)
    expect(support_provider_index_page).to have_content(@provider_hei.provider_name)
    expect(support_provider_index_page).to have_content(@provider_scitt.provider_name)
  end
end
