# frozen_string_literal: true

require "rails_helper"

feature "Filter allocations" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_are_providers_with_allocations
    when_i_visit_the_support_allocations_index_page
  end

  context "adding filters" do
    scenario "by allocation provider name" do
      then_i_can_search_by_allocation_provider_name
      and_when_i_click_apply_filters
      the_correct_provider_shows
    end
  end

  context "removing filters" do
    before do
      given_i_have_filters_selected
    end

    scenario "removing selected filters" do
      i_can_remove_filters
      and_i_can_see_unfiltered_results
    end
  end

private

  def and_there_are_providers_with_allocations
    @allocation_one = create(:allocation, number_of_places: 3)
    @allocation_two = create(:allocation, :with_allocation_uplift, number_of_places: 4)
  end

  def when_i_visit_the_support_allocations_index_page
    support_allocations_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def then_i_can_search_by_allocation_provider_name
    support_allocations_index_page.text_search.set(@allocation_one.provider.provider_name)
  end

  def and_when_i_click_apply_filters
    support_allocations_index_page.apply_filters.click
  end

  def the_correct_provider_shows
    expect(support_allocations_index_page.providers.length).to eq(1)
    expect(support_allocations_index_page).to have_content(@allocation_one.provider.provider_name)
    expect(support_allocations_index_page).not_to have_content(@allocation_two.provider.provider_name)
  end

  def given_i_have_filters_selected
    then_i_can_search_by_allocation_provider_name
    and_when_i_click_apply_filters
  end

  def i_can_remove_filters
    support_allocations_index_page.remove_filters.click
  end

  def and_i_can_see_unfiltered_results
    expect(support_allocations_index_page.providers.length).to eq 3
    expect(support_allocations_index_page).to have_content(@allocation_one.provider.provider_name)
    expect(support_allocations_index_page).to have_content(@allocation_two.provider.provider_name)
  end
end
