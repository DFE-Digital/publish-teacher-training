# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish - Searching the placement schools list", :js, type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "the search panel is available" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    then_i_see_the_search_panel
  end

  scenario "searching by school name" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("belvidere")
    then_only_these_schools_are_shown("Belvidere School")
    and_i_can_still_save_my_changes
  end

  scenario "searching by postcode, with and without its space" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("SY2 5RJ")
    then_only_these_schools_are_shown("Belvidere School")
    when_i_clear_the_search
    when_i_search_for("sy25rj")
    then_only_these_schools_are_shown("Belvidere School")
  end

  scenario "searching by URN" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("123456")
    then_only_these_schools_are_shown("Belvidere School")
  end

  scenario "searching for something that matches no school" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("zzzz")
    then_i_see_the_no_results_message
    and_no_schools_are_shown
    and_i_can_still_save_my_changes
  end

  scenario "the town a school is in is not searchable" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("shrewsbury")
    then_i_see_the_no_results_message
  end

  scenario "clearing the search returns to the full list" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("belvidere")
    then_only_these_schools_are_shown("Belvidere School")
    when_i_clear_the_search
    then_all_three_schools_are_shown
    and_the_search_box_is_empty
  end

  scenario "choosing Show all schools from the no results message returns to the full list" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("zzzz")
    then_i_see_the_no_results_message
    when_i_choose_show_all_schools_from_the_no_results_message
    then_all_three_schools_are_shown
    and_the_search_box_is_empty
  end

  scenario "a school ticked before searching is still attached after saving" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_tick("Belvidere School")
    and_i_search_for("charlton")
    then_only_these_schools_are_shown("Charlton School")
    when_i_save
    then_the_course_has_these_schools("Belvidere School")
  end

  scenario "selecting all schools while a search is active still attaches every school" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("belvidere")
    when_i_tick("Select all schools")
    when_i_save
    then_the_course_has_these_schools("Belvidere School", "Bridgnorth Endowed School", "Charlton School")
  end

  describe "the suggestions dropdown" do
    scenario "suggests schools once three characters are typed" do
      given_a_course_i_want_to_edit
      when_i_visit_the_publish_course_school_edit_page
      when_i_type("bel")
      then_i_see_the_suggestion("Belvidere School")
    end

    scenario "shows no more than five suggestions" do
      given_the_provider_has_many_schools_sharing_a_name
      given_a_course_i_want_to_edit
      when_i_visit_the_publish_course_school_edit_page
      when_i_type("shared")
      then_i_see_at_most_five_suggestions
    end

    scenario "choosing a suggestion filters the list without ticking anything" do
      given_a_course_i_want_to_edit
      when_i_visit_the_publish_course_school_edit_page
      when_i_type("bel")
      and_i_choose_the_first_suggestion
      then_only_these_schools_are_shown("Belvidere School")
      and_nothing_is_ticked
    end
  end

  context "when the provider has more than 20 schools" do
    before do
      given_the_provider_has_many_schools_sharing_a_name
      given_a_course_i_want_to_edit
      when_i_visit_the_publish_course_school_edit_page
    end

    scenario "every match is shown, however many there are" do
      then_only_the_first_20_schools_are_shown
      when_i_search_for("shared")
      then_the_number_of_schools_shown_is(22)
      and_there_is_no_show_all_schools_button
    end

    scenario "clearing the search collapses the list again" do
      when_i_expand_the_list
      when_i_search_for("shared")
      when_i_clear_the_search
      then_only_the_first_20_schools_are_shown
    end
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider)
    create(:site, provider: @provider, location_name: "Belvidere School", town: "Shrewsbury", postcode: "SY2 5RJ", urn: "123456")
    create(:site, provider: @provider, location_name: "Bridgnorth Endowed School", town: "Bridgnorth", postcode: "WV16 4ER", urn: "234567")
    create(:site, provider: @provider, location_name: "Charlton School", town: "Telford", postcode: "TF1 3FA", urn: "345678")
    @user = create(:user, providers: [@provider])
    given_i_am_authenticated(user: @user)
    @provider.reload
  end

  def given_the_provider_has_many_schools_sharing_a_name
    22.times { |index| create(:site, provider: @provider, location_name: "Shared School #{sprintf('%02d', index)}") }
    @provider.reload
  end

  def given_a_course_i_want_to_edit
    @course = create(:course, provider: @provider, sites: [])
  end

  def when_i_visit_the_publish_course_school_edit_page
    publish_course_school_edit_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      course_code: @course.course_code,
    )
  end

  def when_i_type(query)
    fill_in "Search for a school in the list", with: query
  end

  def when_i_search_for(query)
    when_i_type(query)
    click_button "Search"
  end
  alias_method :and_i_search_for, :when_i_search_for

  def when_i_clear_the_search
    click_button "Clear search"
  end

  def when_i_choose_show_all_schools_from_the_no_results_message
    publish_course_school_edit_page.search_show_all_schools.click
  end

  def when_i_expand_the_list
    publish_course_school_edit_page.show_all_schools.click
  end

  def when_i_tick(label)
    check label
  end

  def when_i_save
    click_link_or_button "Update placement schools"
    expect(page).to have_content("updated")
  end

  def and_i_choose_the_first_suggestion
    page.find(".autocomplete__option", match: :first).click
  end

  def then_i_see_the_search_panel
    expect(page).to have_field("Search for a school in the list")
    expect(page).to have_content("You can also enter a postcode or URN")
    expect(page).to have_button("Search")
    expect(page).to have_button("Clear search")
  end

  def then_only_these_schools_are_shown(*names)
    expect(publish_course_school_edit_page.visible_school_names).to match_array(names)
  end

  def then_all_three_schools_are_shown
    then_only_these_schools_are_shown("Belvidere School", "Bridgnorth Endowed School", "Charlton School")
  end

  def then_the_number_of_schools_shown_is(count)
    expect(publish_course_school_edit_page.visible_school_checkbox_count).to eq(count)
  end

  def then_only_the_first_20_schools_are_shown
    # Wait for the Stimulus controller to finish collapsing the list (it reveals
    # the button only after hiding the overflow rows) before the count assertion,
    # which reads Capybara's synchronous `all` and would otherwise race connect().
    expect(publish_course_school_edit_page).to have_show_all_schools
    then_the_number_of_schools_shown_is(20)
  end

  def and_there_is_no_show_all_schools_button
    expect(publish_course_school_edit_page).to have_no_show_all_schools
  end

  def then_i_see_the_no_results_message
    expect(page).to have_content("No results found. Clear your search and try again.")
  end

  def and_no_schools_are_shown
    then_the_number_of_schools_shown_is(0)
  end

  def and_the_search_box_is_empty
    expect(page).to have_field("Search for a school in the list", with: "")
  end

  def and_i_can_still_save_my_changes
    expect(page).to have_button("Update placement schools")
    expect(page).to have_link("Cancel")
  end

  def and_nothing_is_ticked
    # GOV.UK visually hides the real inputs, so they are only ever found with
    # visible: :all - which also covers the rows the search filtered out.
    expect(page).to have_no_css(".govuk-checkboxes__input:checked", visible: :all)
  end

  def then_i_see_the_suggestion(name)
    expect(page).to have_css(".autocomplete__option", text: name)
  end

  def then_i_see_at_most_five_suggestions
    expect(page).to have_css(".autocomplete__option")
    expect(page.all(".autocomplete__option").count).to be <= 5
  end

  def then_the_course_has_these_schools(*names)
    expect(@course.reload.sites.map(&:location_name)).to match_array(names)
  end
end
