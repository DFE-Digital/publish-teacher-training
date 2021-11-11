# frozen_string_literal: true

require "rails_helper"

feature "Edit an Allocation Uplift" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_are_providers_with_allocations
    when_i_visit_the_allocation_edit_page
  end

  scenario "i can edit the allocation amount" do
    then_i_can_edit_their_allocation_amount
    and_i_click_continue
    and_i_get_redirected_to_allocation_show_page
    with_a_success_message
    and_the_allocation_has_updated
  end

private

  def and_there_are_providers_with_allocations
    @provider = create(:provider)
    @allocation = create(:allocation, provider: @provider, number_of_places: 5, confirmed_number_of_places: 5)
  end

  def when_i_visit_the_allocation_edit_page
    allocation_edit_page.load(id: @allocation.id)
  end

  def then_i_can_edit_their_allocation_amount
    @confirmed_number_of_places = 500
    allocation_edit_page.confirmed_number_of_places.set(@confirmed_number_of_places)
  end

  def and_i_click_continue
    allocation_edit_page.submit.click
  end

  def and_i_get_redirected_to_allocation_show_page
    expect(allocations_show_page).to be_displayed(id: @allocation.id)
  end

  def with_a_success_message
    expect(allocations_show_page).to have_content "Allocation was successfully updated"
  end

  def and_the_allocation_has_updated
    @allocation.reload
    expect(@allocation.confirmed_number_of_places).to eq @confirmed_number_of_places
  end
end
