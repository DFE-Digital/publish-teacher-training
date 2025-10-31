# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding school to provider as an admin" do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider
    and_there_is_a_gias_school
  end

  describe "Adding school to organisation" do
    scenario "With valid details" do
      given_i_visit_the_support_provider_schools_index_page
      and_i_click_add_school
      then_i_am_on_the_school_search_page

      when_i_search_with_an_empty_query
      then_i_see_an_error_message

      when_i_search_with_an_unmatched_query
      then_i_see_a_no_results_message
      then_i_click_change_your_search

      when_i_search_with_an_partial_query
      then_i_see_school_options

      when_i_choose_the_school_i_want_to_add
      then_i_see_the_confirmation_page

      when_i_click_add_school
      then_i_see_a_confirmation_message
      and_the_school_is_in_the_database
    end

    scenario "attempting to add a school with duplicate URN" do
      given_the_provider_already_has_a_school_with_the_same_urn
      given_i_visit_the_support_provider_schools_index_page
      and_i_click_add_school
      then_i_am_on_the_school_search_page

      when_i_search_with_an_partial_query
      then_i_see_school_options

      when_i_choose_the_school_i_want_to_add
      then_i_see_the_confirmation_page

      when_i_click_add_school
      then_i_see_a_duplicate_urn_error
      and_the_school_is_not_added_to_the_database
    end
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def and_there_is_a_provider
    @provider = create(:provider, provider_name: "School of Cats", provider_code: "V01")
  end

  def and_there_is_a_gias_school
    @gias_school = create(:gias_school, {
      urn: "123456",
      name: "Distinct School",
      address1: "123 Fake Street",
      town: "Newtown",
      postcode: "RD9 0AN",
    })
  end

  def given_i_visit_the_support_provider_schools_index_page
    support_provider_schools_index_page.load(recruitment_cycle_year: Find::CycleTimetable.current_year, provider_id: @provider.id)
  end

  def then_i_am_on_the_school_search_page
    expect(page).to have_current_path(search_support_recruitment_cycle_provider_schools_path(recruitment_cycle_year: Find::CycleTimetable.current_year, provider_id: @provider.id))
  end

  def when_i_search_with_an_empty_query
    fill_in "support-providers-schools-search-form-query-field", with: ""
    click_continue
  end

  def then_i_see_an_error_message
    within(".govuk-error-summary") do
      expect(page).to have_content("There is a problem")
      expect(page).to have_content("Enter a URN (unique reference number) or school name")
    end
  end

  def when_i_search_with_an_unmatched_query
    fill_in "support-providers-schools-search-form-query-field", with: "zzz"
    click_continue
  end

  def then_i_see_a_no_results_message
    expect(page).to have_content("No results found for ‘zzz’")
  end

  def when_i_search_with_an_partial_query
    fill_in "support-providers-schools-search-form-query-field", with: "Dis"
    click_continue
  end

  def then_i_see_school_options
    expect(page).to have_content("1 result found for ‘Dis’")
  end

  def when_i_choose_the_school_i_want_to_add
    choose @gias_school.name
    click_continue
  end

  def then_i_click_change_your_search
    click_link_or_button "Change your search"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_content("Add school - School of Cats (V01)")
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("URN123456")
    expect(page).to have_content("Address123 Fake StreetNewtownRD9 0AN")
  end

  def and_i_click_add_school
    click_link_or_button "Add school"
  end
  alias_method :when_i_click_add_school, :and_i_click_add_school

  def then_i_see_a_confirmation_message
    within(".govuk-notification-banner--success") do
      expect(page).to have_content("School added")
    end
  end

  def click_continue
    click_link_or_button "Continue"
  end

  def given_the_provider_already_has_a_school_with_the_same_urn
    # Create an existing site with the same URN as the GIAS school we're trying to add
    @provider.sites.create!(
      location_name: "Existing School with Same URN",
      urn: @gias_school.urn,
      address1: "Different Street",
      town: "Different Town",
      postcode: "SW1A 2AA",
      site_type: :school,
    )
    @initial_school_count = @provider.sites.count
  end

  def then_i_see_a_duplicate_urn_error
    # Check for validation error on the page
    expect(page).to have_content("This school has already been added")
  end

  def and_the_school_is_not_added_to_the_database
    expect(@provider.sites.count).to eq(@initial_school_count)
  end

  def and_the_school_is_in_the_database
    expect(@provider.sites.count).to eq(1)
    added_school = @provider.sites.find_by(urn: @gias_school.urn)
    expect(added_school).to be_present
    expect(added_school.location_name).to eq(@gias_school.name)
  end
end
