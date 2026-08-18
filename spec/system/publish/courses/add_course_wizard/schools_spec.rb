# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard schools step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_multiple_schools
  end

  scenario "choosing a salaried school and continues to study sites page" do
    and_i_have_wizard_state_for_schools(funding_type: "salary")
    when_i_visit_the_wizard_schools_page
    and_the_title_and_description_are_displayed_for_a_salaried_school
    and_i_choose_a_school_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_study_sites_page
  end

  scenario "choosing a non-salaried school and continues to study sites page" do
    and_i_have_wizard_state_for_schools(funding_type: "fee")
    when_i_visit_the_wizard_schools_page
    and_the_title_and_description_are_displayed_for_a_non_salaried_school
    and_i_choose_a_school_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_study_sites_page
  end

  scenario "submitting schools without selecting a school shows validation errors" do
    when_i_visit_the_wizard_schools_page
    and_i_click_continue
    then_i_have_errors_on_the_schools_step
  end

  scenario "single-school provider continues to study sites page without explicitly selecting the only school" do
    given_i_am_authenticated_as_a_provider_user_with_a_school
    and_i_have_wizard_state_for_schools(funding_type: "fee")
    when_i_visit_the_wizard_schools_page
    and_i_click_continue
    then_i_am_taken_to_the_study_sites_page
  end

  scenario "TDA qualification route continues through schools step to study sites page" do
    and_i_have_wizard_state_for_qualifications(level: "primary")
    when_i_visit_the_wizard_qualifications_page
    and_i_choose_qualification("Teacher degree apprenticeship (TDA) with QTS")
    and_i_click_continue
    then_i_am_taken_to_the_schools_page
    and_the_title_and_description_are_displayed_for_a_salaried_school
    and_i_choose_a_school_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_study_sites_page
  end

  scenario "the school address does not repeat the school name" do
    given_i_am_authenticated_as_a_provider_user_with_a_named_school
    and_i_have_wizard_state_for_schools(funding_type: "fee")
    when_i_visit_the_wizard_schools_page
    then_the_school_label_shows_the_name
    and_the_address_is_shown_without_the_school_name
  end

  # Nothing is attached to a course that does not exist yet, so the wizard only
  # ever has schools to add.
  context "when playing back the schools being added", :js do
    before do
      given_i_am_authenticated_as_a_provider_user_with_three_schools
      and_i_have_wizard_state_for_schools(funding_type: "fee")
      when_i_visit_the_wizard_schools_page
    end

    scenario "nothing is played back until a school is chosen" do
      then_i_see_no_summary
    end

    scenario "the schools being added are named back" do
      when_i_check("Alpha Academy")
      then_i_am_told_i_am_adding("Alpha Academy")

      when_i_check("Beta Academy")
      then_i_am_told_i_am_adding("Alpha Academy", "Beta Academy")
      and_i_am_not_told_i_am_removing_anything
    end

    scenario "choosing every school" do
      when_i_check("Alpha Academy")
      and_i_check("Beta Academy")
      and_i_check("Gamma Academy")
      then_i_am_told_i_am_adding_all_schools
    end
  end

  context "when the provider has more than 20 schools", :js do
    before do
      given_i_am_authenticated_as_a_provider_user_with_25_schools
      and_i_have_wizard_state_for_schools(funding_type: "fee")
      when_i_visit_the_wizard_schools_page
    end

    scenario "the list is collapsed to 20 schools and can be expanded" do
      then_only_the_first_20_schools_are_shown
      when_i_click_show_all_schools
      then_all_the_schools_are_shown
    end

    scenario "a school hidden behind the collapse can still be selected and is saved" do
      then_only_the_first_20_schools_are_shown
      when_i_click_show_all_schools
      and_i_choose_the_last_school_in_the_list
      and_i_click_continue
      then_i_am_taken_to_the_study_sites_page
      and_the_last_school_is_stored_in_the_wizard_state
    end

    scenario "a school already selected beyond the first 20 is collapsed but stays selected" do
      given_the_last_school_is_already_selected_in_the_wizard_state
      when_i_visit_the_wizard_schools_page
      then_only_the_first_20_schools_are_shown
      and_the_last_school_is_hidden_but_still_checked
      and_i_click_continue
      then_i_am_taken_to_the_study_sites_page
      and_the_last_school_is_stored_in_the_wizard_state
    end

    scenario "every match is shown, however many there are" do
      then_only_the_first_20_schools_are_shown
      when_i_search_for("school")
      then_the_number_of_schools_shown_is(25)
      and_there_is_no_show_all_schools_button
    end
  end

  context "when searching the list of schools", :js do
    before do
      given_i_am_authenticated_as_a_provider_user_with_searchable_schools
      and_i_have_wizard_state_for_schools(funding_type: "fee")
      when_i_visit_the_wizard_schools_page
    end

    scenario "the search panel is available" do
      then_i_see_the_search_panel
    end

    scenario "searching by school name" do
      when_i_search_for("belvidere")
      then_only_these_schools_are_shown("Belvidere School")
    end

    scenario "searching by postcode" do
      when_i_search_for("SY2 5RJ")
      then_only_these_schools_are_shown("Belvidere School")
    end

    scenario "searching by URN" do
      when_i_search_for("123456")
      then_only_these_schools_are_shown("Belvidere School")
    end

    scenario "searching for something that matches no school" do
      when_i_search_for("zzzz")
      then_i_see_the_no_results_message
      when_i_choose_show_all_schools_from_the_no_results_message
      then_all_the_searchable_schools_are_shown
    end

    scenario "clearing the search returns to the full list" do
      when_i_search_for("belvidere")
      then_only_these_schools_are_shown("Belvidere School")
      when_i_clear_the_search
      then_all_the_searchable_schools_are_shown
    end

    scenario "a school chosen before searching is still selected on continuing" do
      when_i_choose("Belvidere School")
      and_i_search_for("charlton")
      then_only_these_schools_are_shown("Charlton School")
      and_i_click_continue
      then_i_am_taken_to_the_study_sites_page
      and_belvidere_is_stored_in_the_wizard_state
    end

    scenario "the step has no select all control" do
      expect(page).to have_no_field("Select all schools")
    end
  end

private

  def when_i_visit_the_wizard_schools_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :schools,
      state_key: wizard_state_key,
    )
  end

  def when_i_visit_the_wizard_qualifications_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :qualifications,
      state_key: wizard_state_key,
    )
  end

  def and_the_title_and_description_are_displayed_for_a_salaried_school
    expect(page).to have_content("Employing schools")
    expect(page).to have_content("If you do not add all relevant employing schools, you may miss out on potential candidates.")
  end

  def and_the_title_and_description_are_displayed_for_a_non_salaried_school
    expect(page).to have_content("Placement schools")
    expect(page).to have_content("If you do not add all relevant placement schools, you may miss out on potential candidates.")
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_choose_qualification(qualification)
    choose qualification
  end

  def and_i_choose_a_school_from_the_list
    check first_school.location_name
  end

  def then_i_have_errors_on_the_schools_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one school")
  end

  def then_i_am_taken_to_the_study_sites_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :study_sites,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def then_i_am_taken_to_the_schools_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :schools,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  # The schools step lists Provider::School, so the checkbox label and hint come
  # from the joined GIAS record rather than the legacy site.
  #
  # Names are given explicitly rather than left to the factory's
  # Faker::University.name: Capybara's `check` matches label text on a substring,
  # so random names can collide or prefix each other.
  def create_school(provider, name, **gias_school_attributes)
    create(
      :provider_school,
      provider:,
      gias_school: create(:gias_school, name:, **gias_school_attributes),
    )
  end

  def given_i_am_authenticated_as_a_provider_user_with_multiple_schools
    provider = create(:provider, :accredited_provider, sites: [build(:site, :study_site)])
    create_school(provider, "Alpha Academy")
    create_school(provider, "Beta Academy")

    @user = create(:user, providers: [provider])

    given_i_am_authenticated(user: @user)
  end

  # Three, so that choosing two of them is not also choosing all of them.
  def given_i_am_authenticated_as_a_provider_user_with_three_schools
    provider = create(:provider, :accredited_provider, sites: [build(:site, :study_site)])
    create_school(provider, "Alpha Academy")
    create_school(provider, "Beta Academy")
    create_school(provider, "Gamma Academy")

    @user = create(:user, providers: [provider])

    given_i_am_authenticated(user: @user)
  end

  def when_i_check(school_name)
    check school_name
  end
  alias_method :and_i_check, :when_i_check

  def then_i_see_no_summary
    expect(page).to have_no_css(".app-schools-changes")
  end

  def then_i_am_told_i_am_adding(*school_names)
    within(".app-schools-changes__added") do
      expect(page).to have_content(
        "You are adding #{school_names.one? ? '1 school' : "#{school_names.size} schools"}:",
      )
      expect(all("li").map(&:text)).to eq(school_names)
    end
  end

  def then_i_am_told_i_am_adding_all_schools
    expect(page).to have_content("You are adding all schools in your list")
  end

  def and_i_am_not_told_i_am_removing_anything
    within(".app-schools-changes") do
      expect(page).to have_no_content("You are removing")
    end
  end

  def given_i_am_authenticated_as_a_provider_user_with_a_school
    provider = create(:provider, :accredited_provider, sites: [build(:site, :study_site)])
    create_school(provider, "Alpha Academy")

    @user = create(:user, providers: [provider])

    given_i_am_authenticated(user: @user)
  end

  # The study site keeps this provider on the same route as the other scenarios
  # (schools -> study sites). It does not show up in the schools list, which
  # reads Provider#schools.
  #
  # Created in reverse so row order is the opposite of name order: the step sorts
  # on the GIAS name, and which schools fall inside the first 20 would not
  # otherwise prove that sort is applied.
  def given_i_am_authenticated_as_a_provider_user_with_25_schools
    provider = create(:provider, :accredited_provider, sites: [build(:site, :study_site)])
    25.downto(1) { |n| create_school(provider, sprintf("School %02d", n)) }

    @user = create(:user, providers: [provider])

    given_i_am_authenticated(user: @user)
  end

  def given_i_am_authenticated_as_a_provider_user_with_a_named_school
    provider = create(:provider, :accredited_provider)
    create_school(
      provider,
      "Belvidere School",
      address1: "Belvidere Lane",
      address2: "",
      address3: "",
      town: "Shrewsbury",
      county: "Shropshire",
      postcode: "SY2 5RJ",
    )
    create_school(provider, "Alpha Academy")

    @user = create(:user, providers: [provider])

    given_i_am_authenticated(user: @user)
  end

  def school_checkbox_selector
    "input[name='schools[school_uuids][]']"
  end

  # Counts the visible checkbox rows holding a school checkbox. We check the
  # wrapper's visibility (a block element) rather than the input, because GOV.UK
  # visually hides the real <input> element itself.
  def visible_school_checkbox_count
    page.all(".govuk-checkboxes__item", visible: true).count do |item|
      item.has_css?(school_checkbox_selector, visible: :all)
    end
  end

  def first_school
    @first_school ||= provider.schools.min_by(&:location_name)
  end

  def last_school
    @last_school ||= provider.schools.max_by(&:location_name)
  end

  def then_only_the_first_20_schools_are_shown
    # Wait for the Stimulus controller to collapse the list (it reveals the button
    # only after hiding the overflow rows) before the count assertion below, which
    # reads Capybara's synchronous `all` and would otherwise race connect().
    expect(page).to have_button("Show all schools")
    expect(visible_school_checkbox_count).to eq(20)
  end

  def when_i_click_show_all_schools
    click_on "Show all schools"
  end

  def then_all_the_schools_are_shown
    expect(page).to have_no_button("Show all schools")
    expect(visible_school_checkbox_count).to eq(25)
  end

  def then_the_number_of_schools_shown_is(count)
    expect(visible_school_checkbox_count).to eq(count)
  end

  def and_there_is_no_show_all_schools_button
    expect(page).to have_no_button("Show all schools")
  end

  def given_i_am_authenticated_as_a_provider_user_with_searchable_schools
    provider = create(:provider, :accredited_provider, sites: [build(:site, :study_site)])
    create_school(provider, "Belvidere School", town: "Shrewsbury", postcode: "SY2 5RJ", urn: "123456")
    create_school(provider, "Charlton School", town: "Telford", postcode: "TF1 3FA", urn: "345678")

    @user = create(:user, providers: [provider])

    given_i_am_authenticated(user: @user)
  end

  def when_i_search_for(query)
    fill_in "Search for a school in the list", with: query
    click_button "Search"
  end
  alias_method :and_i_search_for, :when_i_search_for

  def when_i_clear_the_search
    click_button "Clear search"
  end

  def when_i_choose_show_all_schools_from_the_no_results_message
    click_on "Show all schools"
  end

  def when_i_choose(name)
    check name
  end

  def then_i_see_the_search_panel
    expect(page).to have_field("Search for a school in the list")
    expect(page).to have_content("You can also enter a postcode or URN")
    expect(page).to have_button("Search")
    expect(page).to have_button("Clear search")
  end

  def then_i_see_the_no_results_message
    expect(page).to have_content("No results found. Clear your search and try again.")
  end

  def visible_school_names
    page.all(".govuk-checkboxes__item", visible: true).filter_map do |item|
      item.find(".govuk-label").text if item.has_css?(school_checkbox_selector, visible: :all)
    end
  end

  def then_only_these_schools_are_shown(*names)
    expect(visible_school_names).to match_array(names)
  end

  def then_all_the_searchable_schools_are_shown
    then_only_these_schools_are_shown("Belvidere School", "Charlton School")
  end

  def and_belvidere_is_stored_in_the_wizard_state
    belvidere = provider.schools.find { |school| school.location_name == "Belvidere School" }

    expect(stored_school_uuids).to contain_exactly(belvidere.uuid)
  end

  def and_i_choose_the_last_school_in_the_list
    check last_school.location_name
  end

  def and_the_last_school_is_stored_in_the_wizard_state
    expect(stored_school_uuids).to contain_exactly(last_school.uuid)
  end

  def given_the_last_school_is_already_selected_in_the_wizard_state
    wizard_state_store.write(school_uuids: [last_school.uuid])
  end

  # A collapsed school keeps its checked state in the DOM even though its row is
  # hidden, so the selection is not visible but is not dropped either.
  def and_the_last_school_is_hidden_but_still_checked
    expect(page).to have_no_css(".govuk-checkboxes__label", text: last_school.location_name)
    expect(page.find(:checkbox, last_school.location_name, visible: :all)).to be_checked
  end

  def then_the_school_label_shows_the_name
    expect(page).to have_css(".govuk-checkboxes__label", text: "Belvidere School")
  end

  def and_the_address_is_shown_without_the_school_name
    hint = page.find(".govuk-hint", text: "Belvidere Lane")

    expect(hint.text).to eq("Belvidere Lane, Shrewsbury, Shropshire, SY2 5RJ")
    expect(hint.text).not_to include("Belvidere School")
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end

  def and_i_have_wizard_state_for_schools(funding_type:)
    wizard_state_store.write(funding_type:)
  end

  def and_i_have_wizard_state_for_qualifications(level:)
    wizard_state_store.write(level:)
  end

  # Built fresh on each call so reads see state written by the browser, rather
  # than a stale snapshot from when the repository was first constructed.
  def wizard_state_repository
    CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )
  end

  def wizard_state_store
    CourseWizard::StateStores::CourseWizardStore.new(repository: wizard_state_repository)
  end

  # Read straight off the repository: the state store only exposes step attributes
  # through a wizard, which we do not have here.
  def stored_school_uuids
    state = wizard_state_repository.read

    Array(state[:school_uuids] || state["school_uuids"]).compact_blank
  end
end
