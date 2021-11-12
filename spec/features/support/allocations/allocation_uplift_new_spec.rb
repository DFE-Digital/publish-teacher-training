# frozen_string_literal: true

require "rails_helper"

feature "Edit an Allocation Uplift" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_theres_a_provider_with_an_allocation_and_no_uplift
    when_i_visit_the_allocation_uplift_new_page
  end

  scenario "i can create a new uplift amount" do
    then_i_can_create_an_uplift
    and_i_click_continue
    and_i_get_redirected_to_allocation_show_page
    with_a_success_message
    and_the_allocation_has_an_uplift
  end

private

  def and_theres_a_provider_with_an_allocation_and_no_uplift
    @provider = create(:provider)
    @allocation = create(:allocation, provider: @provider, number_of_places: 5)
  end

  def when_i_visit_the_allocation_uplift_new_page
    allocation_uplift_new_page.load(allocation_id: @allocation.id)
  end

  def then_i_can_create_an_uplift
    @allocation_uplift_amount = 5
    expect(allocation_uplift_new_page).to have_content "Create an Allocation Uplift for #{@provider.provider_name}"
    allocation_uplift_new_page.allocation_uplift_amount.set(@allocation_uplift_amount)
  end

  def and_i_click_continue
    allocation_uplift_new_page.submit.click
  end

  def and_i_get_redirected_to_allocation_show_page
    expect(allocations_show_page).to be_displayed(id: @allocation.id)
  end

  def with_a_success_message
    expect(allocations_show_page).to have_content "Allocation Uplift was successfully created"
  end

  def and_the_allocation_has_an_uplift
    expect(@allocation.allocation_uplift).to be_present
    expect(@allocation.allocation_uplift.uplifts).to eq @allocation_uplift_amount
  end
end
