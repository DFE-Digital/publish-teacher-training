# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Suggestions in the provider schools filter", :js, type: :system do
  scenario "Provider picks a school from the suggestions and filters the list" do
    given_i_am_authenticated_as_a_provider_user_with_schools
    when_i_visit_the_schools_page
    then_i_see_all_of_my_schools

    when_i_type_into_the_filter("Bramble")
    then_only_my_matching_school_is_suggested

    when_i_choose_the_suggestion
    and_i_filter_the_list
    then_i_only_see_the_matching_school
  end

  def given_i_am_authenticated_as_a_provider_user_with_schools
    provider = create(:provider)

    create(
      :provider_school,
      provider:,
      gias_school: create(:gias_school, name: "Bramblewood Primary", town: "Leeds", postcode: "LS1 1AA"),
    )
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

  def when_i_type_into_the_filter(text)
    fill_in "Search for a school in the list", with: text
  end

  def suggestions
    page.find("ul.autocomplete__menu")
  end

  def then_only_my_matching_school_is_suggested
    expect(suggestions).to have_text("Bramblewood Primary (Leeds, LS1 1AA)")
    expect(suggestions).to have_no_text("Harborne Academy")
  end

  def when_i_choose_the_suggestion
    suggestions.find("li", text: "Bramblewood Primary").click
  end

  def and_i_filter_the_list
    click_on "Search"
  end

  def then_i_only_see_the_matching_school
    expect(page).to have_text("Bramblewood Primary")
    expect(page).to have_no_text("Harborne Academy")
  end
end
