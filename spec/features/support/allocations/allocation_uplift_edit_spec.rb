# frozen_string_literal: true

require "rails_helper"

feature "Edit an Allocation Uplift" do
  let(:user) { create(:user, :admin) }
  let(:provider) { create(:provider) }
  let(:allocation) { create(:allocation, :with_allocation_uplift, provider: provider, number_of_places: 5) }
  let(:new_allocation_uplift) { 500 }

  before do
    given_i_am_authenticated(user: user)
    and_there_are_providers_with_allocations_and_uplifts
    when_i_visit_the_allocation_uplift_edit_page
  end

  scenario "i can edit the allocation uplift amount" do
    then_i_can_edit_their_allocation_uplift_amount
    and_i_click_continue
    and_i_get_redirected_to_allocation_show_page
    and_the_allocation_has_updated
  end

private

  def and_there_are_providers_with_allocations_and_uplifts
    allocation
  end

  def when_i_visit_the_allocation_uplift_edit_page
    allocation_uplift_edit_page.load(uplift_id: allocation.allocation_uplift.id, allocation_id: allocation.id)
  end

  def then_i_can_edit_their_allocation_uplift_amount
    allocation_uplift_edit_page.allocation_uplift_amount.set(new_allocation_uplift)
  end

  def and_i_click_continue
    allocation_uplift_edit_page.submit.click
  end

  def and_i_get_redirected_to_allocation_show_page
    expect(allocations_show_page).to be_displayed(id: allocation.id)
  end

  def and_the_allocation_has_updated
    allocation.reload
    expect(allocation.allocation_uplift.uplifts).to eq new_allocation_uplift
  end
end
