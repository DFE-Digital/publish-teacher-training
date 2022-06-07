require "rails_helper"

RSpec.feature "PE allocations", { can_edit_current_and_next_cycles: false } do
  before do
    allow(Settings.features.allocations).to receive(:state).and_return("open")
    allow(Settings).to receive(:allocation_cycle_year).and_return(2022)

    and_there_is_a_previous_recruitment_cycle
    and_there_is_a_previous_training_provider
    and_there_is_a_training_provider
    and_there_is_a_previous_repeat_allocation
  end

  context "Repeat allocations" do
    context "Accredited body has previously requested a repeat allocation for a training provider" do
      scenario "Accredited body views PE allocations page" do
        given_i_am_authenticated(user: user_with_accredited_bodies)
        when_i_visit_allocations_page
        then_i_see_the_pe_allocations_page
      end
    end

    scenario "Accredited body requests PE allocations" do
      given_i_am_authenticated(user: user_with_accredited_bodies)
      when_i_visit_allocations_page
      then_i_see_the_pe_allocations_page
      and_i_see_only_repeat_allocation_statuses

      when_i_click_confirm_choice_for_the_repeat_allocation
      then_i_see_new_request_pe_allocations_page
      when_i_click_yes_on_the_new_repeat_page
      and_i_click_continue_on_the_new_repeat_page
      and_i_see_the_corresponding_page_title("Request sent")
    end

    scenario "Accredited body decides not to request PE allocations" do
      given_i_am_authenticated(user: user_with_accredited_bodies)
      when_i_visit_allocations_page
      then_i_see_the_pe_allocations_page
      and_i_see_only_repeat_allocation_statuses

      when_i_click_confirm_choice_for_the_repeat_allocation
      then_i_see_new_request_pe_allocations_page

      when_i_click_no_on_the_new_repeat_page

      and_i_click_continue_on_the_new_repeat_page
      and_i_see_the_confirmation_page
      and_i_see_the_corresponding_page_title("Thank you")
    end
  end

  context "Accredited body previously declined a repeat PE allocation" do
    scenario "Accredited body updates an existing PE allocation to 'yes'" do
      and_there_is_a_declined_allocation
      given_i_am_authenticated(user: user_with_accredited_bodies)
      when_i_visit_allocations_page
      then_i_see_the_pe_allocations_page

      when_i_click_change_for_the_declined_allocation

      then_i_see_allocations_edit_page(declined_allocation)

      when_i_click_yes_on_the_edit_page

      and_i_click_continue_on_the_edit_page
      and_i_see_the_corresponding_page_title("Request sent")
    end
  end

  context "Accredited body has previously accepted a repeat PE allocation" do
    scenario "Accredited body updates an existing PE allocation to 'no'" do
      and_there_is_a_repeat_allocation

      given_i_am_authenticated(user: user_with_accredited_bodies)
      when_i_visit_allocations_page

      then_i_see_the_pe_allocations_page

      when_i_click_change_for_the_repeat_allocation
      then_i_see_allocations_edit_page(repeat_allocation)

      when_i_click_no_on_the_new_repeat_page
      and_i_click_continue_on_the_edit_page
      and_i_see_the_corresponding_page_title("#{training_provider.provider_name} Thank you")
    end
  end

private

  def when_i_visit_allocations_page(provider: accredited_body_with_allocations)
    allocations_page.load(provider_code: provider.provider_code,
                          recruitment_cycle_year: provider.recruitment_cycle_year)
  end

  def user_with_accredited_bodies
    @user_with_accredited_bodies ||= create(:user, providers:
      [accredited_body_with_allocations])
  end

  def accredited_body_with_allocations
    @accredited_body_with_allocations ||= build(:provider, :accredited_body,
                                                recruitment_cycle: current_recruitment_cycle)
  end

  def previous_repeat_allocation
    @previous_repeat_allocation ||= create(
      :allocation,
      :repeat,
      accredited_body: accredited_body_with_allocations,
      provider: previous_training_provider,
    )
  end

  def repeat_allocation
    @repeat_allocation ||= create(
      :allocation,
      :repeat,
      accredited_body: accredited_body_with_allocations,
      provider: training_provider,
    )
  end

  def training_provider
    @training_provider ||= create(:provider, recruitment_cycle: current_recruitment_cycle)
  end

  def previous_training_provider
    @previous_training_provider ||= create(:provider, provider_code: training_provider.provider_code, recruitment_cycle: previous_recruitment_cycle)
  end

  def previous_recruitment_cycle
    @previous_recruitment_cycle ||= find_or_create(:recruitment_cycle, :previous)
  end

  def current_recruitment_cycle
    @current_recruitment_cycle ||= find_or_create(:recruitment_cycle)
  end

  def declined_allocation
    @declined_allocation ||= create(:allocation, :declined, accredited_body: accredited_body_with_allocations, provider: training_provider, number_of_places: 0)
  end

  def next_allocation_cycle_period_text
    "#{Settings.allocation_cycle_year + 1} to #{Settings.allocation_cycle_year + 2}"
  end

  def then_i_see_the_pe_allocations_page
    expect(allocations_page).to be_displayed(provider_code: accredited_body_with_allocations.provider_code, recruitment_cycle_year: accredited_body_with_allocations.recruitment_cycle_year)
    expect(allocations_page.header).to have_content("Request PE courses for #{next_allocation_cycle_period_text}")
  end

  def and_i_see_only_repeat_allocation_statuses
    expect(allocations_page).to have_repeat_allocations
    expect(allocations_page).not_to have_initial_allocations
    expect(allocations_page.rows.first.provider_name.text).to eq(previous_training_provider.provider_name)
  end

  def and_i_see_only_initial_allocation_statuses
    expect(allocations_page).to have_initial_allocations_table
    expect(allocations_page).not_to have_repeat_allocations
    expect(allocations_page.rows.first.provider_name.text).to eq(previous_training_provider.provider_name)
  end

  def when_i_click_confirm_choice_for_the_repeat_allocation
    expect(allocations_page.repeat_allocations.first.actions).to have_content("Confirm choice")
    allocations_page.repeat_allocations.first.actions.click
  end

  def then_i_see_allocations_edit_page(allocation)
    expect(publish_allocations_edit_page).to be_displayed(
      provider_code: accredited_body_with_allocations.provider_code, recruitment_cycle_year: accredited_body_with_allocations.recruitment_cycle_year,
    )
    expect(publish_allocations_edit_page.url_matches["query"]["id"]).to eq(allocation.id.to_s)
    expect(publish_allocations_edit_page.header).to have_content("Do you want to request PE for this organisation?")
  end

  def then_i_see_new_request_pe_allocations_page
    expect(publish_new_repeat_request_page).to be_displayed(
      provider_code: accredited_body_with_allocations.provider_code, recruitment_cycle_year: accredited_body_with_allocations.recruitment_cycle_year, training_provider_code: training_provider.provider_code,
    )

    expect(publish_new_repeat_request_page.header).to have_content("Do you want to request PE for this organisation?")
  end

  def when_i_click_yes_on_the_new_repeat_page
    publish_new_repeat_request_page.yes.click
  end

  def when_i_click_yes_on_the_edit_page
    publish_allocations_edit_page.yes.click
  end

  def when_i_click_no_on_the_new_repeat_page
    publish_new_repeat_request_page.no.click
  end

  def when_i_click_change_on_the_allocation_page_for_the_repeat_allocation
    expect(allocations_page.repeat_allocations.first.actions).to have_content("Change")

    allocations_page.repeat_allocations.first.actions.click
  end

  def and_i_click_continue_on_the_edit_page
    publish_allocations_edit_page.continue_button.click
  end

  def and_i_click_continue_on_the_new_repeat_page
    publish_new_repeat_request_page.continue_button.click
  end

  def and_i_see_the_confirmation_page
    expect(publish_allocations_show_page).to be_displayed
  end

  def and_i_see_the_corresponding_page_title(title)
    expect(publish_allocations_show_page.page_heading).to have_content(title)
  end

  alias_method :and_there_is_a_previous_recruitment_cycle, :previous_recruitment_cycle
  alias_method :and_there_is_a_previous_repeat_allocation, :previous_repeat_allocation
  alias_method :and_there_is_a_previous_training_provider, :previous_training_provider
  alias_method :and_there_is_a_training_provider, :training_provider
  alias_method :and_there_is_a_declined_allocation, :declined_allocation
  alias_method :and_there_is_a_repeat_allocation, :repeat_allocation
  alias_method :when_i_click_change_for_the_declined_allocation, :when_i_click_change_on_the_allocation_page_for_the_repeat_allocation
  alias_method :when_i_click_change_for_the_repeat_allocation, :when_i_click_change_on_the_allocation_page_for_the_repeat_allocation
end
