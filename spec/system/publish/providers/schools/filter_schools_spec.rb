# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filter a provider's list of schools" do
  scenario "Provider narrows the list down to one school and clears it again" do
    given_i_am_authenticated_as_a_provider_user_with_schools
    when_i_visit_the_schools_page
    then_i_see_all_of_my_schools
    and_i_can_clear_the_filter

    when_i_filter_for("Bramblewood")
    then_i_only_see_the_matching_school
    and_i_am_told_what_i_filtered_for("Bramblewood")

    when_i_clear_the_filter
    then_i_see_all_of_my_schools

    when_i_filter_for("Nowhereville")
    then_i_am_told_there_are_no_results
    and_i_am_not_told_what_i_filtered_for("Nowhereville")

    when_i_choose_to_view_all_schools
    then_i_see_all_of_my_schools
  end

  def given_i_am_authenticated_as_a_provider_user_with_schools
    provider = create(:provider)

    create(:provider_school, provider:, gias_school: create(:gias_school, name: "Bramblewood Primary"))
    create(:provider_school, provider:, gias_school: create(:gias_school, name: "Harborne Academy"))

    given_i_am_authenticated(user: create(:user, providers: [provider]))
  end

  def provider
    @current_user.providers.first
  end

  def when_i_visit_the_schools_page
    visit publish_provider_recruitment_cycle_schools_path(
      provider.provider_code, provider.recruitment_cycle_year
    )
  end

  def then_i_see_all_of_my_schools
    expect(page).to have_text("Bramblewood Primary")
    expect(page).to have_text("Harborne Academy")
  end

  def and_i_can_clear_the_filter
    expect(page).to have_link("Clear search")
  end

  def and_i_am_told_what_i_filtered_for(text)
    expect(page).to have_text("Showing results for “#{text}”")
    expect(page).to have_css("strong", text: "“#{text}”")
  end

  def and_i_am_not_told_what_i_filtered_for(text)
    expect(page).to have_no_text("Showing results for “#{text}”")
  end

  def when_i_filter_for(text)
    fill_in "Search for a school in the list", with: text
    click_on "Search"
  end

  def then_i_only_see_the_matching_school
    expect(page).to have_text("Bramblewood Primary")
    expect(page).to have_no_text("Harborne Academy")
  end

  def when_i_clear_the_filter
    click_on "Clear search"
  end

  def then_i_am_told_there_are_no_results
    expect(page).to have_text("No schools found with that search.")
    expect(page).to have_no_text("Bramblewood Primary")
  end

  def when_i_choose_to_view_all_schools
    click_on "View all schools"
  end
end
