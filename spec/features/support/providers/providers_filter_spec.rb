# frozen_string_literal: true

require "rails_helper"

feature "View filtered providers" do
  let(:user) { create(:user, :admin) }

  before do
    given_i_am_authenticated(user:)
    and_there_are_providers
    when_i_visit_the_support_provider_index_page
  end

  scenario "i can view and filter the providers" do
    then_i_see_the_providers

    when_i_filter_by_provider
    then_i_see_providers_filtered_by_provider_name

    when_i_remove_the_provider_filter
    then_i_see_the_unfiltered_providers

    when_i_filter_by_course_code
    then_i_see_the_providers_filtered_by_course_code

    when_i_remove_the_course_code_filter
    then_i_see_the_unfiltered_providers

    when_i_filter_by_provider_code_and_course_code
    then_i_see_the_providers_filtered_by_provider_code_and_course_code

    when_i_remove_the_provider_code_and_course_code_filter
    then_i_see_the_unfiltered_providers
  end

  def and_there_are_providers
    create(:provider, provider_name: "Really big school", provider_code: "A01", courses: [build(:course, course_code: "2VVZ")])
    create(:provider, provider_name: "Slightly smaller school", provider_code: "A02", courses: [build(:course, course_code: "2VVZ")])
  end

  def when_i_visit_the_support_provider_index_page
    support_provider_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def then_i_see_the_providers
    expect(support_provider_index_page.providers.size).to eq(2)
  end

  alias_method :then_i_see_the_unfiltered_providers, :then_i_see_the_providers

  def when_i_filter_by_provider
    fill_in "Provider name or code", with: "Really big school"
    click_button "Apply filters"
  end

  def when_i_filter_by_course_code
    fill_in "Provider name or code", with: ""
    fill_in "Course code", with: "2VVZ"
    click_button "Apply filters"
  end

  def when_i_filter_by_provider_code_and_course_code
    fill_in "Provider name or code", with: "A01"
    fill_in "Course code", with: "2vvZ"
    click_button "Apply filters"
  end

  def then_i_see_providers_filtered_by_provider_name
    expect(support_provider_index_page.providers.size).to eq(1)
    expect(support_provider_index_page.providers.first.text).to have_content("Really big school A01")
  end

  alias_method :then_i_see_the_providers_filtered_by_provider_code_and_course_code, :then_i_see_providers_filtered_by_provider_name

  def then_i_see_the_providers_filtered_by_course_code
    expect(support_provider_index_page.providers.size).to eq(2)
    expect(support_provider_index_page.providers.first.text).to have_content("Really big school A01")
    expect(support_provider_index_page.providers.last.text).to have_content("Slightly smaller school A02")
  end

  def when_i_remove_the_provider_filter
    click_link "Remove Really big school provider search filter"
  end

  def when_i_remove_the_course_code_filter
    click_link "Remove 2VVZ course search filter"
  end

  def when_i_remove_the_provider_code_and_course_code_filter
    click_link "Remove A01 provider search filter"
    click_link "Remove 2vvZ course search filter"
  end
end
