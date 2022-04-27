require "rails_helper"

RSpec.feature "PE allocations" do
  before do
    allow(Settings.features.allocations).to receive(:state).and_return("open")
    and_there_is_a_previous_recruitment_cycle
    and_there_is_a_training_provider
  end

  scenario "Accredited body requests new PE allocations" do
    given_i_am_authenticated(user: user_with_accredited_bodies)

    when_i_visit_allocations_page(accredited_body_with_no_allocations)

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    and_i_choose_a_training_provider

    and_i_click_continue(who_are_you_requesting_a_course_for_page)
    then_i_see_number_of_places_page

    when_i_fill_in_the_number_of_places_input
    and_i_click_continue(number_of_places_page)
    then_i_see_check_your_information_page
    and_the_number_is_the_one_i_entered

    when_i_click_change
    then_i_see_number_of_places_page

    when_i_change_the_number
    and_i_click_continue(number_of_places_page)
    then_i_see_check_your_information_page
    and_the_number_is_the_new_one

    when_i_click_send_request
    then_i_see_confirmation_page
  end

  scenario "Accredited body requests new PE allocations for new training provider" do
    given_i_am_authenticated(user: user_with_accredited_bodies)

    when_i_visit_allocations_page(accredited_body_with_no_allocations)

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider
    and_i_click_continue(who_are_you_requesting_a_course_for_page)
    then_i_see_pick_a_provider_page

    when_i_click_on_a_provider_from_search_results
    then_i_see_number_of_places_page
    and_i_see_provider_name("Acme SCITT")

    when_i_fill_in_the_number_of_places_input
    and_i_click_continue(number_of_places_page)
    then_i_see_check_your_information_page
    and_the_number_is_the_one_i_entered
  end

  scenario "Accredited body requests new PE allocations for training provider they can't find on first page" do
    given_i_am_authenticated(user: user_with_accredited_bodies)

    when_i_visit_allocations_page(accredited_body_with_no_allocations)

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider_that_does_not_exist
    and_i_click_continue(who_are_you_requesting_a_course_for_page)
    then_i_see_the_request_new_pe_allocations_page
    and_i_see_error_message_that_no_providers_exist_for_search
  end

  scenario "Accredited body requests new PE allocations for training provider they can't find on pick a provider page" do
    given_i_am_authenticated(user: user_with_accredited_bodies)

    when_i_visit_allocations_page(accredited_body_with_no_allocations)

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider
    and_i_click_continue(who_are_you_requesting_a_course_for_page)
    then_i_see_pick_a_provider_page

    when_i_search_again_for_a_training_provider_that_does_not_exist
    and_i_click_search_again
    then_i_see_the_request_new_pe_allocations_page
    and_i_see_error_message_that_no_providers_exist_for_search
  end

  scenario "Accredited body requests new PE allocations for training provider with empty search" do
    given_i_am_authenticated(user: user_with_accredited_bodies)

    when_i_visit_allocations_page(accredited_body_with_no_allocations)

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider_with_empty_string
    and_i_click_continue(who_are_you_requesting_a_course_for_page)

    then_i_see_the_request_new_pe_allocations_page
    and_i_see_error_message_that_i_must_add_more_info
  end

  scenario "Accredited body searches for provider with string containing only one character" do
    given_i_am_authenticated(user: user_with_accredited_bodies)

    when_i_visit_allocations_page(accredited_body_with_no_allocations)

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider_with_string_containing_one_character
    and_i_click_continue(who_are_you_requesting_a_course_for_page)

    then_i_see_the_request_new_pe_allocations_page
    and_i_see_error_message_that_my_search_query_must_contain_two_characters
  end

  context "Accredited body enters number of places" do
    scenario "Accredited body submits form without specifying number of places" do
      given_i_am_authenticated(user: user_with_accredited_bodies)

      when_i_visit_allocations_page(accredited_body_with_no_allocations)

      when_i_click_choose_an_organisation_button
      then_i_see_the_request_new_pe_allocations_page

      and_i_choose_a_training_provider
      and_i_click_continue(who_are_you_requesting_a_course_for_page)

      then_i_see_number_of_places_page

      and_i_click_continue(number_of_places_page)
      then_i_see_number_of_places_page
      and_i_see_error_message_that_i_must_enter_a_number
    end

    scenario "Accredited body enters '0'" do
      given_i_am_authenticated(user: user_with_accredited_bodies)

      when_i_visit_allocations_page(accredited_body_with_no_allocations)

      when_i_click_choose_an_organisation_button
      then_i_see_the_request_new_pe_allocations_page

      and_i_choose_a_training_provider
      and_i_click_continue(who_are_you_requesting_a_course_for_page)

      then_i_see_number_of_places_page

      when_i_fill_in_the_number_of_places_input_with_zero
      and_i_click_continue(number_of_places_page)
      then_i_see_number_of_places_page
      and_i_see_error_message_that_i_must_enter_a_number
    end

    scenario "Accredited body enters a float (1.1)" do
      given_i_am_authenticated(user: user_with_accredited_bodies)

      when_i_visit_allocations_page(accredited_body_with_no_allocations)

      when_i_click_choose_an_organisation_button
      then_i_see_the_request_new_pe_allocations_page

      and_i_choose_a_training_provider
      and_i_click_continue(who_are_you_requesting_a_course_for_page)

      then_i_see_number_of_places_page

      when_i_fill_in_the_number_of_places_input_with_a_float
      and_i_click_continue(number_of_places_page)
      then_i_see_number_of_places_page
      and_i_see_error_message_that_i_must_enter_a_number
    end

    scenario "Accredited body enters a non-numeric character" do
      given_i_am_authenticated(user: user_with_accredited_bodies)

      when_i_visit_allocations_page(accredited_body_with_no_allocations)

      when_i_click_choose_an_organisation_button
      then_i_see_the_request_new_pe_allocations_page

      and_i_choose_a_training_provider
      and_i_click_continue(who_are_you_requesting_a_course_for_page)

      then_i_see_number_of_places_page

      when_i_fill_in_the_number_of_places_input_with_a_letter
      and_i_click_continue(number_of_places_page)
      then_i_see_number_of_places_page
      and_i_see_error_message_that_i_must_enter_a_number
    end
  end

  def and_there_is_a_training_provider
    training_provider
  end

  def and_there_is_a_previous_recruitment_cycle
    previous_recruitment_cycle
  end

  def when_i_visit_allocations_page(provider)
    allocations_page.load(provider_code: provider.provider_code,
                          recruitment_cycle_year: provider.recruitment_cycle_year)
  end

  def user_with_accredited_bodies
    @user_with_accredited_bodies ||= create(:user, providers:
      [accredited_body_with_allocations, accredited_body_with_no_allocations])
  end

  def accredited_body_with_allocations
    @accredited_body ||= build(:provider, :accredited_body,
                               recruitment_cycle: current_recruitment_cycle)
  end

  def accredited_body_with_no_allocations
    @accredited_body_with_no_allocations ||= build(:provider, :accredited_body,
                                                   recruitment_cycle: current_recruitment_cycle)
  end

  def previous_recruitment_cycle
    @previous_recruitment_cycle ||= find_or_create(:recruitment_cycle, :previous)
  end

  def current_recruitment_cycle
    @current_recruitment_cycle ||= find_or_create(:recruitment_cycle)
  end

  def accredited_body
    @accredited_body ||= build(:provider, :accredited_body,
                               recruitment_cycle: current_recruitment_cycle)
  end

  def given_i_am_signed_in_as_a_user_from_the_accredited_body
    signed_in_user(provider: accredited_body)
  end

  def training_provider
    @training_provider ||= create(:provider, provider_name: "Acme SCITT", recruitment_cycle: current_recruitment_cycle)
  end

  def when_i_click_choose_an_organisation_button
    allocations_page.choose_an_organisation.click
  end

  def then_i_see_the_request_new_pe_allocations_page
    expect(who_are_you_requesting_a_course_for_page.header).to have_content("Who are you requesting a course for?")
  end

  def and_i_choose_a_training_provider
    who_are_you_requesting_a_course_for_page.providers.first.choose(accredited_body_with_no_allocations.provider_name)
  end

  def when_i_search_for_a_training_provider
    who_are_you_requesting_a_course_for_page.find_an_organisation_not_listed_above.choose

    who_are_you_requesting_a_course_for_page.training_provider_search.fill_in(with: "ACME")
  end

  def when_i_click_on_a_provider_from_search_results
    pick_a_provider_page.providers.first.link.click
  end

  def and_i_see_provider_name(provider_name)
    expect(page).to have_content(provider_name)
  end

  def and_i_click_continue(page)
    page.continue.click
  end

  def then_i_see_number_of_places_page
    expect(number_of_places_page.header.text).to have_content("How many places would you like to request?")
  end

  def then_i_see_pick_a_provider_page
    expect(pick_a_provider_page.header).to have_content("Pick a provider")
  end

  def when_i_search_for_a_training_provider_that_does_not_exist
    who_are_you_requesting_a_course_for_page.find_an_organisation_not_listed_above.choose
    who_are_you_requesting_a_course_for_page.training_provider_search.fill_in(with: "donotexist")
  end

  def and_i_see_error_message_that_no_providers_exist_for_search
    expect(page)
      .to have_content("We could not find this organisation - please check your information and try again.")
  end

  def when_i_search_again_for_a_training_provider_that_does_not_exist
    page.find("span", text: "Try another provider").click
    who_are_you_requesting_a_course_for_page.training_provider_search.fill_in(with: "donotexist")
  end

  def and_i_click_search_again
    page.click_on("Search again")
  end

  def when_i_search_for_a_training_provider_with_empty_string
    who_are_you_requesting_a_course_for_page.find_an_organisation_not_listed_above.choose
    who_are_you_requesting_a_course_for_page.training_provider_search.fill_in(with: "")
  end

  def when_i_search_for_a_training_provider_with_string_containing_one_character
    who_are_you_requesting_a_course_for_page.find_an_organisation_not_listed_above.choose
    who_are_you_requesting_a_course_for_page.training_provider_search.fill_in(with: "x")
  end

  def and_i_see_error_message_that_i_must_add_more_info
    expect(page).to have_content("You need to add some information")
  end

  def and_i_see_error_message_that_my_search_query_must_contain_two_characters
    expect(page).to have_content("Please enter a minimum of two characters")
  end

  def and_i_see_error_message_that_i_must_enter_a_number
    expect(page).to have_content("You must enter a number")
  end

  def when_i_fill_in_the_number_of_places_input
    number_of_places_page.number_of_places_field.fill_in(with: "2")
  end

  def when_i_fill_in_the_number_of_places_input_with_a_letter
    number_of_places_page.number_of_places_field.fill_in(with: "3a")
  end

  def when_i_fill_in_the_number_of_places_input_with_zero
    number_of_places_page.number_of_places_field.fill_in(with: "0")
  end

  def when_i_fill_in_the_number_of_places_input_with_a_float
    number_of_places_page.number_of_places_field.fill_in(with: "1.1")
  end

  def then_i_see_check_your_information_page
    expect(check_your_info_page.header.text).to have_content("Check your information before sending your request")
  end

  def and_the_number_is_the_one_i_entered
    expect(check_your_info_page.number_of_places.text).to have_content("2")
  end

  def when_i_click_change
    check_your_info_page.change_link.click
  end

  def when_i_change_the_number
    number_of_places_page.number_of_places_field.fill_in(with: "3")
  end

  def and_the_number_is_the_new_one
    expect(check_your_info_page.number_of_places.text).to eq("3")
  end

  def when_i_click_send_request
    check_your_info_page.send_request_button.click
  end

  def then_i_see_confirmation_page
    expect(publish_allocations_show_page.page_heading).to have_content("Request sent")
  end
end
