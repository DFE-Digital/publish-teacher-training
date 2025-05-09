# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filter providers" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_are_providers_with_courses
    when_i_visit_the_providers_index_page
  end

  context "adding filters" do
    scenario "by provider name" do
      then_i_can_search_by_provider_name
      and_when_i_click_apply_filters
      the_correct_provider_shows
    end

    scenario "by provider code" do
      then_i_can_search_by_code
      and_when_i_click_apply_filters
      the_correct_provider_shows
    end

    scenario "by course code" do
      then_i_can_search_by_course_code
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

  def and_there_are_providers_with_courses
    @course = create(:course)
    @provider_one = create(:provider, courses: [@course])
    @provider_two = create(:provider)
  end

  def when_i_visit_the_providers_index_page
    support_provider_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def then_i_can_search_by_provider_name
    support_provider_index_page.provider_name_or_code_search.set(@provider_one.provider_name)
  end

  def then_i_can_search_by_code
    support_provider_index_page.provider_name_or_code_search.set(@provider_one.provider_code)
  end

  def and_when_i_click_apply_filters
    support_provider_index_page.apply_filters.click
  end

  def the_correct_provider_shows
    expect(support_provider_index_page.providers.length).to eq(1)
    expect(support_provider_index_page).to have_content(@provider_one.provider_name)
    expect(support_provider_index_page).to have_no_content(@provider_two.provider_name)
  end

  def then_i_can_search_by_course_code
    support_provider_index_page.course_code_search.set(@provider_one.courses.first.course_code)
  end

  def given_i_have_filters_selected
    then_i_can_search_by_provider_name
    then_i_can_search_by_course_code
    and_when_i_click_apply_filters
  end

  def i_can_remove_filters
    support_provider_index_page.remove_filters.click
  end

  def and_i_can_see_unfiltered_results
    expect(support_provider_index_page.providers.length).to eq 3
    expect(support_provider_index_page).to have_content(@provider_one.provider_name)
    expect(support_provider_index_page).to have_content(@provider_two.provider_name)
  end
end
