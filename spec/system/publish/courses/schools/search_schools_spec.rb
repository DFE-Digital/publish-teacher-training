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

  scenario "the search box is white, not the grey of the panel behind it" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    then_the_search_box_is_white
  end

  scenario "the panel is a plain grey box, with no rule down its edge" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    then_the_panel_is_grey_with_no_border
  end

  scenario "the search box fills the panel, with the button beside it" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    then_the_search_box_fills_the_panel
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

  # Emptying the box and pressing Search says the same thing as Clear search, so
  # it has to be answered the same way.
  scenario "searching with an empty box returns to the full list" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("belvidere")
    then_only_these_schools_are_shown("Belvidere School")
    when_i_search_for("")
    then_all_three_schools_are_shown
    and_i_can_select_all_schools
  end

  scenario "searching with an empty box takes back the no results message" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("zzzz")
    then_i_see_the_no_results_message
    when_i_search_for("")
    then_i_see_no_no_results_message
    and_all_three_schools_are_still_shown
  end

  # The box sits inside the form that saves the schools, so Enter has to be
  # caught: it searches, and never submits. "be" is below the three characters
  # that open the suggestions, so the menu is closed and the key is ours.
  scenario "pressing Enter in the search box searches instead of saving" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_type("be")
    and_i_press_enter_in_the_search_box
    then_only_these_schools_are_shown("Belvidere School")
    and_i_can_still_save_my_changes
  end

  scenario "pressing Enter in an empty search box returns to the full list" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("belvidere")
    then_only_these_schools_are_shown("Belvidere School")
    when_i_type("")
    and_i_press_enter_in_the_search_box
    then_all_three_schools_are_shown
  end

  # Enter on a button in the panel belongs to that button. The search box's own
  # Enter handler has to leave them alone.
  scenario "Clear search can be pressed with the keyboard" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("belvidere")
    and_i_press_enter_on("Clear search")
    then_all_three_schools_are_shown
    and_the_search_box_is_empty
  end

  scenario "Show all schools can be pressed with the keyboard" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("zzzz")
    then_i_see_the_no_results_message
    and_i_press_enter_on("Show all schools")
    then_all_three_schools_are_shown
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

  # Select all attaches every school, including the ones a search has filtered
  # out of view, so it is hidden while a search is active rather than left
  # offering to do something wider than what is on screen.
  scenario "select all is hidden while a search is active" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    then_i_can_select_all_schools
    when_i_search_for("belvidere")
    then_i_cannot_select_all_schools
    when_i_clear_the_search
    then_i_can_select_all_schools
  end

  scenario "select all is back after choosing Show all schools from the no results message" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("zzzz")
    then_i_cannot_select_all_schools
    when_i_choose_show_all_schools_from_the_no_results_message
    then_i_can_select_all_schools
  end

  scenario "select all still attaches every school once the search is cleared" do
    given_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
    when_i_search_for("belvidere")
    when_i_clear_the_search
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

    scenario "shows the town and postcode as plain text, not markup" do
      given_a_course_i_want_to_edit
      when_i_visit_the_publish_course_school_edit_page
      when_i_type("bel")
      then_i_see_the_suggestion("Belvidere School (Shrewsbury, SY2 5RJ)")
      and_the_suggestion_shows_no_markup
    end

    scenario "shows no more than five suggestions" do
      given_the_provider_has_many_schools_sharing_a_name
      given_a_course_i_want_to_edit
      when_i_visit_the_publish_course_school_edit_page
      when_i_type("shared")
      then_i_see_at_most_five_suggestions
    end

    # The dropdown is a typing aid, not an action: choosing from it fills the
    # box and nothing more, so the list only ever changes when Search is pressed.
    scenario "choosing a suggestion fills the search box and leaves the list alone" do
      given_a_course_i_want_to_edit
      when_i_visit_the_publish_course_school_edit_page
      when_i_type("bel")
      and_i_choose_the_first_suggestion
      then_the_search_box_holds("Belvidere School")
      and_all_three_schools_are_still_shown
      and_nothing_is_ticked
    end

    scenario "searching after choosing a suggestion filters to that school" do
      given_a_course_i_want_to_edit
      when_i_visit_the_publish_course_school_edit_page
      when_i_type("bel")
      and_i_choose_the_first_suggestion
      and_i_click_search
      then_only_these_schools_are_shown("Belvidere School")
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

  # :with_provider_school copies the site's name, town, postcode and URN onto a
  # matching GIAS school, which is what the list and the search read from.
  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider)
    create(:site, :with_provider_school, provider: @provider, location_name: "Belvidere School", town: "Shrewsbury", postcode: "SY2 5RJ", urn: "123456")
    create(:site, :with_provider_school, provider: @provider, location_name: "Bridgnorth Endowed School", town: "Bridgnorth", postcode: "WV16 4ER", urn: "234567")
    create(:site, :with_provider_school, provider: @provider, location_name: "Charlton School", town: "Telford", postcode: "TF1 3FA", urn: "345678")
    @user = create(:user, providers: [@provider])
    given_i_am_authenticated(user: @user)
    @provider.reload
  end

  def given_the_provider_has_many_schools_sharing_a_name
    22.times do |index|
      create(:site, :with_provider_school, provider: @provider, location_name: "Shared School #{sprintf('%02d', index)}")
    end
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

  def and_i_click_search
    click_button "Search"
  end

  def when_i_search_for(query)
    when_i_type(query)
    and_i_click_search
  end
  alias_method :and_i_search_for, :when_i_search_for

  def and_i_press_enter_in_the_search_box
    page.find_field("Search for a school in the list").send_keys(:enter)
  end

  # Playwright focuses the element before pressing, so this is the keyboard
  # route to a button rather than a click dressed up as one.
  def and_i_press_enter_on(label)
    page.find_button(label).send_keys(:enter)
  end

  def when_i_clear_the_search
    click_button "Clear search"
  end

  def when_i_choose_show_all_schools_from_the_no_results_message
    publish_course_school_edit_page.show_all_schools.click
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

  # accessible-autocomplete leaves the enhanced input transparent, which shows
  # the panel's grey through it unless we paint it white.
  def then_the_search_box_is_white
    background = page.evaluate_script(
      "getComputedStyle(document.getElementById('school-search')).backgroundColor",
    )

    expect(background).to eq("rgb(255, 255, 255)")
  end

  def then_only_these_schools_are_shown(*names)
    expect(publish_course_school_edit_page.visible_school_names).to match_array(names)
  end

  def then_all_three_schools_are_shown
    then_only_these_schools_are_shown("Belvidere School", "Bridgnorth Endowed School", "Charlton School")
  end
  alias_method :and_all_three_schools_are_still_shown, :then_all_three_schools_are_shown

  def then_the_search_box_holds(query)
    expect(page).to have_field("Search for a school in the list", with: query)
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

  # GOV.UK visually hides the real checkbox, so the label is what tells us
  # whether the control is on screen.
  def then_i_can_select_all_schools
    expect(page).to have_css(".govuk-checkboxes__label", text: "Select all schools")
    expect(page).to have_css(".govuk-body", exact_text: "or")
  end
  alias_method :and_i_can_select_all_schools, :then_i_can_select_all_schools

  def then_i_cannot_select_all_schools
    expect(page).to have_no_css(".govuk-checkboxes__label", text: "Select all schools")
    # The "or" that joins select all to the individual checkboxes goes with it.
    expect(page).to have_no_css(".govuk-body", exact_text: "or")
  end

  def then_i_see_the_no_results_message
    expect(page).to have_content("No results found. Clear your search and try again.")
  end

  # Asserted by its container, not its words: the visually hidden live region
  # announces a failed search with the same string.
  def then_i_see_no_no_results_message
    expect(page).to have_no_css(".app-school-search__no-results")
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

  # dfe-autocomplete escapes an option's appended text before rendering it, so
  # any markup we send arrives on screen as its own source.
  def and_the_suggestion_shows_no_markup
    expect(page).to have_no_css(".autocomplete__option", text: "<")
  end

  # The background is asserted alongside the border because on its own the
  # border assertion would also pass if the panel lost its styling entirely.
  def then_the_panel_is_grey_with_no_border
    style = page.evaluate_script(<<~JS)
      (() => {
        const style = getComputedStyle(document.querySelector('.app-school-search'))
        return JSON.stringify({ border: style.borderLeftWidth, background: style.backgroundColor })
      })()
    JS

    # rgb(243, 242, 241) is govuk-colour("light-grey").
    expect(JSON.parse(style)).to eq("border" => "0px", "background" => "rgb(243, 242, 241)")
  end

  def then_the_search_box_fills_the_panel
    widths = page.evaluate_script(<<~JS)
      JSON.stringify({
        row: document.querySelector('.app-school-search__row').getBoundingClientRect().width,
        input: document.getElementById('school-search').getBoundingClientRect().width
      })
    JS
    row, input = JSON.parse(widths).values_at("row", "input")

    # The Search button and the gap take the rest; anything much narrower means
    # the input has collapsed to its content width instead of filling the row.
    expect(input).to be > (row * 0.8)
  end

  def then_i_see_at_most_five_suggestions
    expect(page).to have_css(".autocomplete__option")
    expect(page.all(".autocomplete__option").count).to be <= 5
  end

  def then_the_course_has_these_schools(*names)
    expect(@course.reload.schools.map { |course_school| course_school.provider_school.location_name })
      .to match_array(names)
  end
end
