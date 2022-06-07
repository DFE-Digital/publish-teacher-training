require "rails_helper"

RSpec.feature "PE allocations", { can_edit_current_and_next_cycles: false } do
  before do
    allow(Settings.features.allocations).to receive(:state).and_return("open")
    allow(Settings).to receive(:allocation_cycle_year).and_return(2022)
    and_there_is_a_previous_recruitment_cycle
  end

  context "updating an initial allocation" do
    scenario "changing the number of places for an allocation" do
      given_i_am_signed_in_as_a_user_from_the_accredited_body
      and_the_accredited_body_has_an_initial_allocation

      when_i_visit_allocations_page
      then_i_see_the_pe_allocations_page
      then_it_shows_the_initial_allocaions_table

      when_i_click_change_for_the_initial_allocations
      then_i_see_do_you_want_page
      and_i_click_continue_on_the_do_you_want_page
      then_i_see_an_error_message

      when_i_select_yes_with_error
      and_i_click_continue_on_the_do_you_want_page
      then_i_see_edit_number_of_places_page

      when_i_fill_in_the_number_of_places_input
      and_i_click_continue_on_the_number_of_places_page
      then_see_the_check_answers_page
      and_the_number_is_the_one_i_entered

      when_i_click_change
      then_i_see_edit_number_of_places_page
      and_i_see_the_updated_number_of_places
      and_i_click_continue_on_the_number_of_places_page

      when_i_click_send_request
      then_i_see_confirmation_page
    end

    scenario "cancelling a request for a new allocation" do
      given_i_am_signed_in_as_a_user_from_the_accredited_body
      and_the_accredited_body_has_an_initial_allocation

      when_i_visit_allocations_page

      and_i_click_change_for_the_initial_allocations

      then_i_see_do_you_want_page

      when_i_select_no
      and_i_click_continue_on_the_do_you_want_page
      then_i_see_the_confirm_deletion_page
    end

    context "validations" do
      context "Accredited body updates number of places" do
        scenario "Accredited body enters nothing" do
          given_i_am_signed_in_as_a_user_from_the_accredited_body
          and_the_accredited_body_has_an_initial_allocation

          when_i_visit_allocations_page

          and_i_click_change_for_the_initial_allocations

          then_i_see_do_you_want_page

          when_i_select_yes
          and_i_click_continue_on_the_do_you_want_page
          then_i_see_edit_number_of_places_page

          when_i_fill_in_the_number_of_places_input_with_nothing
          and_i_click_continue_on_the_number_of_places_page

          then_i_see_edit_number_of_places_page
          and_i_see_error_message_that_i_must_enter_a_number
        end

        scenario "Accredited body enters '0'" do
          given_i_am_signed_in_as_a_user_from_the_accredited_body
          and_the_accredited_body_has_an_initial_allocation

          when_i_visit_allocations_page

          and_i_click_change_for_the_initial_allocations

          then_i_see_do_you_want_page

          when_i_select_yes
          and_i_click_continue_on_the_do_you_want_page
          then_i_see_edit_number_of_places_page

          when_i_fill_in_the_number_of_places_input_with_zero
          and_i_click_continue_on_the_number_of_places_page

          then_i_see_edit_number_of_places_page
          and_i_see_error_message_that_i_must_enter_a_number
        end

        scenario "Accredited body enters a float (1.1)" do
          given_i_am_signed_in_as_a_user_from_the_accredited_body
          and_the_accredited_body_has_an_initial_allocation

          when_i_visit_allocations_page

          and_i_click_change_for_the_initial_allocations

          then_i_see_do_you_want_page

          when_i_select_yes
          and_i_click_continue_on_the_do_you_want_page
          then_i_see_edit_number_of_places_page

          when_i_fill_in_the_number_of_places_input_with_a_float
          and_i_click_continue_on_the_number_of_places_page

          then_i_see_edit_number_of_places_page
          and_i_see_error_message_that_i_must_enter_a_number
        end

        scenario "Accredited body enters a non-numeric character" do
          given_i_am_signed_in_as_a_user_from_the_accredited_body
          and_the_accredited_body_has_an_initial_allocation

          when_i_visit_allocations_page

          and_i_click_change_for_the_initial_allocations

          then_i_see_do_you_want_page

          when_i_select_yes
          and_i_click_continue_on_the_do_you_want_page
          then_i_see_edit_number_of_places_page

          when_i_fill_in_the_number_of_places_input_with_a_letter_and_number
          and_i_click_continue_on_the_number_of_places_page

          then_i_see_edit_number_of_places_page
          and_i_see_error_message_that_i_must_enter_a_number
        end
      end
    end
  end

private

  def when_i_click_change_for_the_initial_allocations
    expect(allocations_page.initial_allocations.first.actions).to have_content("Change")
    allocations_page.initial_allocations.first.actions.click
  end

  def then_it_shows_the_initial_allocaions_table
    expect(allocations_page.initial_allocations.first.provider_name.text).to eq training_provider_with_allocation.provider_name
    expect(allocations_page.initial_allocations.first.status.text).to eq "2 PLACES REQUESTED"

    expect(allocations_page).not_to have_repeat_allocations
  end

  def then_i_see_the_pe_allocations_page
    expect(allocations_page).to be_displayed(provider_code: accredited_body_with_allocations.provider_code, recruitment_cycle_year: accredited_body_with_allocations.recruitment_cycle_year)
    expect(allocations_page.header).to have_content("Request PE courses for #{next_allocation_cycle_period_text}")
  end

  def when_i_visit_allocations_page(provider: accredited_body_with_allocations)
    allocations_page.load(provider_code: provider.provider_code,
                          recruitment_cycle_year: provider.recruitment_cycle_year)
  end

  def previous_recruitment_cycle
    @previous_recruitment_cycle ||= find_or_create(:recruitment_cycle, :previous)
  end

  def current_recruitment_cycle
    @current_recruitment_cycle ||= find_or_create(:recruitment_cycle)
  end

  def accredited_body
    accredited_body_with_allocations
  end

  def given_i_am_signed_in_as_a_user_from_the_accredited_body
    given_i_am_authenticated(user: user_with_accredited_bodies)
  end

  def user_with_accredited_bodies
    @user_with_accredited_bodies ||= create(:user, providers:
      [accredited_body_with_allocations])
  end

  def accredited_body_with_allocations
    @accredited_body_with_allocations ||= build(:provider, :accredited_body,
                                                recruitment_cycle: current_recruitment_cycle)
  end

  def training_provider
    @training_provider ||= build(:provider, recruitment_cycle: current_recruitment_cycle)
  end

  def training_provider_with_fee_funded_pe
    @training_provider_with_fee_funded_pe ||= build(:provider, recruitment_cycle: current_recruitment_cycle)
  end

  def training_provider_with_allocation
    @training_provider_with_allocation ||= build(:provider, recruitment_cycle: current_recruitment_cycle)
  end

  def initial_allocation
    @initial_allocation ||= create(
      :allocation, :initial,
      accredited_body: accredited_body,
      provider: training_provider_with_allocation,
      number_of_places: 2
    )
  end

  def next_allocation_cycle_period_text
    "#{Settings.allocation_cycle_year + 1} to #{Settings.allocation_cycle_year + 2}"
  end

  def when_i_click_change
    check_answers_page.change_link.click
  end

  def then_i_see_do_you_want_page
    expect(do_you_want_page.header).to have_content("Do you want to request PE for this organisation?")
  end

  def then_i_see_do_you_want_page_old
    expect(page.find("h1")).to have_content("Do you want to request PE for this organisation?")
  end

  def then_i_see_an_error_message
    expect(page).to have_content("Select one option")
  end

  def when_i_select_yes
    do_you_want_page.yes.click
  end

  def when_i_select_yes_with_error
    choose "Yes"
  end

  def when_i_select_no
    do_you_want_page.no.click
  end

  def and_i_click_continue_on_the_do_you_want_page
    and_i_click_continue(do_you_want_page)
  end

  def and_i_click_continue_on_the_number_of_places_page
    and_i_click_continue(number_of_places_page)
  end

  def and_i_click_continue(page)
    page.continue.click
  end

  def then_i_see_edit_number_of_places_page
    expect(number_of_places_page.header).to have_content("How many places would you like to request?")
  end

  def when_i_fill_in_the_number_of_places_input
    number_of_places_page.number_of_places_field.fill_in(with: "10")
  end

  def when_i_fill_in_the_number_of_places_input_with_zero
    number_of_places_page.number_of_places_field.fill_in(with: "0")
  end

  def when_i_fill_in_the_number_of_places_input_with_a_float
    number_of_places_page.number_of_places_field.fill_in(with: "1.1")
  end

  def when_i_fill_in_the_number_of_places_input_with_a_letter_and_number
    number_of_places_page.number_of_places_field.fill_in(with: "3a")
  end

  def when_i_fill_in_the_number_of_places_input_with_nothing
    number_of_places_page.number_of_places_field.fill_in(with: "")
  end

  def then_see_the_check_answers_page
    expect(check_answers_page.header).to have_content("Check your information before sending your request")
  end

  def and_the_number_is_the_one_i_entered
    expect(check_answers_page.number_of_places.text).to have_content("10")
  end

  def and_i_see_the_updated_number_of_places
    expect(number_of_places_page.number_of_places_field.value).to have_content("10")
  end

  def when_i_click_send_request
    check_answers_page.send_request_button.click
  end

  def then_i_see_confirmation_page
    expect(publish_allocations_show_page.page_heading).to have_content("Request sent")
  end

  def then_i_see_the_confirm_deletion_page
    expect(page.find("h1")).to have_content("Thank you")
  end

  def and_i_see_error_message_that_i_must_enter_a_number
    expect(page).to have_content("You must enter a number")
  end

  alias_method :and_there_is_a_previous_recruitment_cycle, :previous_recruitment_cycle
  alias_method :and_the_accredited_body_has_an_initial_allocation, :initial_allocation

  alias_method :and_i_click_change_for_the_initial_allocations, :when_i_click_change_for_the_initial_allocations
end
