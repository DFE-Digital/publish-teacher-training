# frozen_string_literal: true

require "rails_helper"

feature "Edit an Allocation Uplift" do
  let(:user) { create(:user, :admin) }
  let(:provider) { create(:provider) }
  let(:allocation) { create(:allocation, provider: provider, number_of_places: 5) }

  before do
    given_i_am_authenticated(user: user)
    and_theres_a_provider_with_an_allocation_and_no_uplift
    when_i_visit_the_allocation_uplift_new_page
  end

  scenario "i can create a new uplift amount" do
    then_i_can_create_an_uplift
    and_i_click_continue
    and_i_get_redirected_to_allocation_show_page
    and_the_allocation_has_an_uplift
  end

private

  def and_theres_a_provider_with_an_allocation_and_no_uplift
    allocation
  end

  def when_i_visit_the_allocation_uplift_new_page
    allocation_uplift_new_page.load(allocation_id: allocation.id)
  end

  def then_i_can_create_an_uplift
    expect(allocation_uplift_new_page).to have_content "Create an Allocation Uplift for #{provider.provider_name}"
    allocation_uplift_new_page.allocation_uplift_amount.set(5)
  end

  def and_i_click_continue
    allocation_uplift_new_page.submit.click
  end

  def and_i_get_redirected_to_allocation_show_page
    expect(allocations_show_page).to be_displayed(id: allocation.id)
  end

  def and_the_allocation_has_an_uplift
    allocation.reload
    expect(allocation.allocation_uplift).to be_present
  end
end
